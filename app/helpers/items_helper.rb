module ItemsHelper


    def path_to_me(jump)
        content_tag("br","nnn")
        jumps = []
        while jump
            jumps << jump
            jump = jump.parent
        end

        result = ""
        jumps.reverse.each do |j|
            logger.info("jump #{j.from_user.name}")

            result += j.from_user.name
            result += " to "
        end
        return result+"You"

    end

    def path_to(jump)
        content_tag("br","nnn")
        jumps = []
        while jump
            jumps << jump
            jump = jump.parent
        end

        result = "You "
        jumps.each do |j|
            logger.info("jump #{j.from_user.name}")

            result += " to "
            result += j.to_user.name

        end


        return result

    end




    def title_help
        return '<div id="help">
            *Short description of the job.<br/>
                Examples:                     <br/>
                Carpenter for house renovation<br/>
                Ruby on Rails programmer
        </div>' unless self.current_user.show_help==false
    end

    def description_help
        return '<div id="help">
               *Description of the job.<br/>
                Should include:<br/>
                -description of the part offering the job<br/>
                -nature of work<br/>
                -working hours<br/>
                -duration of work, eg full time, part time, 6 month contract<br/>
                -special requirements, eg driving licence, certifications etc.<br/>
                -commences at, eg. immediate, august 2008 <br/>
           </div>' unless self.current_user.show_help==false
    end

    def location_help
        return '<div id="help">
               *City and country. Street address if possible             
              </div>' unless self.current_user.show_help==false
    end

    def forward_help
        return '<div id="help">
               * When you relay a job to one of your connections we dispatch an email to them informing them about the event.<br/>
               You can relay jobs to newly created users, but they will have to activate their account before they can see the item<br/>
               relays to users that have not activated their account are marked with \'you relayed*\'
              </div>' unless self.current_user.show_help==false
    end


    def create_help
        return '<div id="help">
               * After the job opportunity is registered you will be able to relay it to your connections
              </div>' unless self.current_user.show_help==false
    end

    def missing_help
        return '<div id="help">
               * If you wish to relay this job opening to people not on this list then it is easy accomplish this.<br/>
                 Click the \'Connections\' link in the top menu and follow instructions.           
              </div>' unless self.current_user.show_help==false
    end

    def comment_help
        return '<div id="help">
               * Include here additional information you wish to relay to the recipients           
              </div>' unless self.current_user.show_help==false
    end

    def link_help
        return '<div id="help">
               * Click \'Reply\' to compose a message to the job initiator<br/>
                Click \'Relay\' to relay this job opportunity to one of your connections
              </div>' unless self.current_user.show_help==false
    end

    def link_help_with_application
        return '<div id="help">
               * Click \'Reply\' to compose a message to the job initiator<br/>
                Click \'Apply\' to apply for this job opening                           
              </div>' unless self.current_user.show_help==false
    end


end
