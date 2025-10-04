module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      set_current_user || reject_unauthorized_connection
    end

    private
      def set_current_user
        if user_session = UserSession.find_by(id: cookies.signed[:session_id])
          self.current_user = user_session.user
        end
      end
  end
end
