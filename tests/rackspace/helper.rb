module Shindo
  class Tests
    
    def given_a_load_balancer_service(&block)
      @service = Fog::Rackspace::LoadBalancers.new
      instance_eval(&block)
    end
    
    def given_a_load_balancer(&block)
        @lb = @service.load_balancers.create({
            :name => ('fog' + Time.now.to_i.to_s),
            :protocol => 'HTTP',
            :port => 80,
            :virtual_ips => [{ :type => 'PUBLIC'}],
            :nodes => [{ :address => '1.1.1.1', :port => 80, :condition => 'ENABLED'}]
          })
        @lb.wait_for { ready? }
      begin
        instance_eval(&block)
      ensure
        @lb.wait_for { ready? }
        @lb.destroy
      end
    end
  
    def wait_for_server_state(service, server_id, state, error_states=nil)
      current_state = nil
      until current_state == state
        current_state = service.get_server(server_id).body['server']['status']
        if error_states
          raise "Error occurred! Server should have transitioned to '#{state}' not '#{current_state}'" if Array(error_states).include?(current_state)
        end
        sleep 10
      end
      sleep 30
    end

  end  
end
