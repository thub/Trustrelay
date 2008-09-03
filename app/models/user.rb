require 'digest/sha1'
class User < ActiveRecord::Base
    # Virtual attribute for the unencrypted password
    attr_accessor :password

    validates_presence_of     :login,  :name
    validates_presence_of     :password,                   :if => :password_required?
    validates_presence_of     :password_confirmation,      :if => :password_required?
    validates_length_of       :password, :within => 4..40, :if => :password_required?
    validates_confirmation_of :password,                   :if => :password_required?
    validates_uniqueness_of   :login,  :case_sensitive => false
      validates_format_of :login,
              :with => /\A([^@\s]+)@((?:[-a-z0-9]+.)+[a-z]{2,})\Z/i  ,
    :message => "not a valid email address"
    before_save :encrypt_password

    

    # user who initiated this user
    belongs_to :initiator,:class_name => "User"

    # collection of users I initiated
    has_many :users,
            :foreign_key => 'initiator_id',
            :class_name => 'User',
            :order => "name"

    # has many connected peers
    has_many :relationships,
            :foreign_key => 'owner_id',
            :class_name => 'Relationship',
            :dependent => :destroy

    has_many :toConnections,
            :through => :relationships,
            :source => :target

    has_many :initiators,
            :foreign_key => 'target_id',
            :class_name => 'Relationship',
            :dependent => :destroy


    has_many :fromConnections,
            :through => :initiators,
            :source => :owner

    has_many :senders,
            :foreign_key => 'to_user_id',
            :class_name => 'Reply',
            :dependent => :destroy


    has_many :receivers,
            :foreign_key => 'from_user_id',
            :class_name => 'Reply',
            :dependent => :destroy


    def connectedUsers
        self.toConnections + self.fromConnections
    end

    def connections
        self.relationships + self.initiators
    end

    def replies
        self.senders + self.receivers
    end


    # has many connected peers
    has_many :items,
            :foreign_key => 'owner_id',
            :class_name => 'Item',
            :dependent => :destroy,
            :order=>"updated_at desc"



    has_many :jumps_from,
            :foreign_key => 'from_user_id',
            :class_name => 'Jump',
            :dependent => :destroy,
            :order => "created_at desc"



    has_many :jumps_to,
            :foreign_key => 'to_user_id',
            :class_name => 'Jump',
            :dependent => :destroy

     has_many :transient_items, :through => :jumps_to, :source => :item


    def allItems
        self.items + self.transient_items
    end


    # prevents a user from submitting a crafted form that bypasses activation
    # anything else you want your user to change should be added here.
    attr_accessible :login, :password, :password_confirmation, :description , :name, :password_reset_code, :initiationMessage

    acts_as_state_machine :initial => :pending
    state :passive
    state :pending, :enter => :make_activation_code
    state :active,  :enter => :do_activate
    state :suspended
    state :deleted, :enter => :do_delete

    event :register do
        transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
    end

    event :activate do
        transitions :from => :pending, :to => :active
    end

    event :suspend do
        transitions :from => [:passive, :pending, :active], :to => :suspended
    end

    event :delete do
        transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
    end

    event :unsuspend do
        transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
        transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
        transitions :from => :suspended, :to => :passive
    end

    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def self.authenticate(login, password)
        u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt


        #        logger.info("got user "+u.login)
        #        logger.info(" with password "+password)
        u && u.authenticated?(password) ? u : nil
    end

    # Encrypts some data with the salt.
    def self.encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    # Encrypts the password with the user salt
    def encrypt(password)
        self.class.encrypt(password, salt)
    end

    def authenticated?(password)
        crypted_password == encrypt(password)
    end

    def remember_token?
        remember_token_expires_at && Time.now.utc < remember_token_expires_at
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
        remember_me_for 2.weeks
    end

    def remember_me_for(time)
        remember_me_until time.from_now.utc
    end

    def remember_me_until(time)
        self.remember_token_expires_at = time
        self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
        save(false)
    end

    def forget_me
        self.remember_token_expires_at = nil
        self.remember_token            = nil
        save(false)
    end

    # Returns true if the user has just been activated.
    def recently_activated?
        @activated
    end



    def password_required?
        crypted_password.blank? || !password.blank?
    end

    def make_activation_code
        if(self.activation_code == nil)
            self.deleted_at = nil
            self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
            logger.info("in make_activation_code code for "+self.login+" is "+self.activation_code)
        else
            logger.info("in make_activation_code code for "+self.login+" keeping  "+self.activation_code)
        end
    end

    def do_delete
        self.deleted_at = Time.now.utc
        self.relationships.each do |relationship|
            relationship.destroy
        end

        self.initiators.each do |relationship|
            relationship.destroy
        end

        self.items.each do |item|
            # clear all jumps related to this item
            item.jumps.each do |jump|
                jump.destroy
            end

            item.destroy
        end


        # for jumps where I am in the middle somewhere we do nothing as the user is still present but marked with deleted_at


        self.login = "#{self.login} deleted #{Time.now.utc.to_formatted_s(:long)}"
        self.name = "Deleted"

        self.save
    end

    def do_activate
        @activated = true
        self.activated_at = Time.now.utc
        self.deleted_at = self.activation_code = nil
    end


    def change_password
        @change_password
    end

    def forgot_password
        @forgotten_password = true
        self.make_password_reset_code
    end

    def reset_password
        # First update the password_reset_code before setting the
        # reset_password flag to avoid duplicate mail notifications.
        update_attributes(:password_reset_code => nil)
        @reset_password = nil
    end

    # Used in user_observer
    def recently_forgot_password?
        @forgotten_password
    end

    # Used in user_observer
    def recently_reset_password?
        @reset_password
    end

    # Used in user_observer
    def recently_activated?
        @activated
    end


    protected
    def make_password_reset_code
        self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    protected
    # before filter
    def encrypt_password
        return if password.blank?
        self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
        self.crypted_password = encrypt(password)
    end






end
