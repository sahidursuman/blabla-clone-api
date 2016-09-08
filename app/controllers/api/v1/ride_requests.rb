module API
  module V1
    class RideRequests < Grape::API
    	resource :ride_requests do
        desc "Create a ride request"
        params do
          requires :ride_id, type: Integer, desc: "requested ride id"
          requires :places,  type: Integer, desc: "requested places"
        end
        post do
          authenticate!
          ride_request = RideRequest.new(
            ride_id:   params[:ride_id],
            places:    params[:places],
            passenger: current_user
          )
          if ride_request.save
            requested = ride_request.ride.user_requested?(current_user)
            ride_request = ride_request.ride.user_ride_request(current_user) if requested
            ride = ride_request.ride
            present ride, with: Entities::RideShow, current_user: current_user
          else
            status 406
            ride_request.errors.messages
          end
        end

        desc "Change ride request status"
        params do
          requires :id,     type: Integer, desc: "ride request id"
          requires :status, type: String,  desc: "ride request status"
        end
        route_param :id do
          put do
            authenticate!
            if ride_request
              ride_request.update(status: params[:status])
              ride = ride_request.ride
              present ride, with: Entities::RideShowOwner
            else
              status 406
              ride_request.errors.messages
            end
          end
        end
      end

      helpers do
        def ride_request
          @ride_request ||= RideRequest.find(params[:id])
        end

        def ride_request_owner?
          ride_request.ride.driver.id == current_user.id if current_user.present?
        end
      end
    end
  end
end
