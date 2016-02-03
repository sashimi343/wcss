require 'sinatra/base'

module UserAuth
    def authorize?
        session.key? :registration_id
    end
end
