module RelationshipsHelper


      def status_help
        return '<div id="help">
            *Relationship status:<br/>
                <b>pending</b> - the connection request has not yet been accepted<br/>
                <b>active</b>  &nbsp;&nbsp;&nbsp;&nbsp;- connection request has been accepted<br/>                
        </div>' unless self.current_user.show_help==false
    end
end
