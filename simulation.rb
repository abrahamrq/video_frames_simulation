require 'pry'

# MAX TRANSFER UNIT
MTU = 1500
############################# Initial clients ##################################

k = 15
clients_current_frame = []
k.times do 
  clients_current_frame << 0
end
current_client = 0

# client rates
tp = 2.0
# clients_rate = 1.0 / tp
clients_rate = tp
client_arrival_time = clients_rate

################################################################################

############################# GENERATE FRAMES ##################################

frames = []
f = File.open("data/Terse_Jurassic.dat") or die "Unable to open file..."

# RANDOM INITIAL FRAME
# initial_frame = rand(10000..50000)
# STATIC INITIAL FRAME
initial_frame = 10000
aux = 0
f.each_line do |line|
  if aux > initial_frame + 2000
    break
  elsif aux > initial_frame
    frames << line.gsub("\n",'')
  end
  aux += 1
end

frames.map! do |frame|
  (frame.to_f / MTU).ceil
end 

# number_of_packets = frames.inject(0){|sum,x| sum + x }

################################################################################

# Initial error probability
e = 0.001 * k

# Quantity of packets on the buffer
n = 0
# Time
t = 0.0
arrival_time = 0.0
departure_time = 0.0

# Total of messages (fail + success)
total_messages = 0

# Completed packets
completed_packets=0
# Busy time
b = 0.0
# Last time (helper for busy time)
last_time=0.0

#area
dt=0.0
s=0.0

# SETUP
velocity_of_bandwidth = 0.000222
velocity_of_arrival = 0.001
max_capacity = 200

rejected_requests = 0
errors_at_sending = 0
clients_finished = 0
max_clients_in_system = 0
 
while (t < 1000)
  # if there are no more clients it ends the simulation
  if clients_current_frame.size == 0
    break
  else
    if (t > client_arrival_time)
      # new arrival time of a client
      client_arrival_time += clients_rate
      # ENABLE DYNAMIC CLIENTS if comment this line, there will be no new
      # clients
      clients_current_frame << 0
      if max_clients_in_system < clients_current_frame.size
        max_clients_in_system = clients_current_frame.size
      end
    else
      # Choose betwen an arrival or a departure
      if (arrival_time <= departure_time)
        # Update total messages
        total_messages += 1
        # If packets will fit in buffer put them in it
        if n+(frames[clients_current_frame[current_client]]) <= max_capacity
          # update time
          t=arrival_time
          # update area
          dt=t-last_time
          s=s+n*dt
          # Add packets to buffer
          n=n+(frames[clients_current_frame[current_client]])
          frames[clients_current_frame[current_client]].times do
            # print '.'
          end
          # update last time
          last_time=t
          # new arrival time
          z= velocity_of_arrival
          arrival_time=t+z
          # if there is only one packet in the system update departure time
          if (n==1)
            z= velocity_of_bandwidth
            b=b+z
            departure_time=t+z
          end
          # clients control, if the client finished delete it from the list
          # if not, update current frame of the user and choose next user
          if clients_current_frame[current_client] + 1 >= frames.size
            clients_finished += 1
            clients_current_frame.delete_at(current_client)
          else
            clients_current_frame[current_client] += 1
            current_client = (current_client + 1) % clients_current_frame.size
          end
        else
          # if the packet didn't fit update rejected messages
          rejected_requests += 1
          z= velocity_of_arrival
          arrival_time=t+z
        end
      else
        # update time
        t = departure_time
        z = velocity_of_bandwidth
        # compute error probability
        e = 0.001 * clients_current_frame.size
        ## REMOVE TRUE TO ENABLE ERRORS
        if (rand() < e)
          errors_at_sending += 1
        else
          completed_packets += 1
        end
        if (n > 0)
          # remove packet from buffer and complete packet
          # print "*"
          dt=t-last_time
          n=n-1
          b=b+z
          if (n==0)
            # no more packets? finish with simulation
            departure_time=1000000
          end
          s=s+n*dt
          last_time=t
          end
        # update departure time
        departure_time=t+z
      end
    end
  end
end

if b > t
  b = t
end

p_of_rejections = rejected_requests / total_messages

x_nurx = completed_packets/t
u_nurx = b/t
n_nurx = s/t
r_nurx = n_nurx/x_nurx

puts "\n"
puts "Total time of simulation        : #{t}"
puts "Completed messages              : #{completed_packets}" 
puts "Errors at sending               : #{errors_at_sending}"
puts "Clients subscribed(final)       : #{clients_current_frame.size}"
puts "Clients finished                : #{clients_finished}"
puts "Max clients on system           : #{max_clients_in_system}"
puts "N                               : #{n_nurx}"
puts "U                               : #{u_nurx}"
puts "R                               : #{r_nurx}"
puts "X                               : #{x_nurx}"
puts "Requests rejected               : #{rejected_requests}"
puts "probability(reject of buffer)   : #{p_of_rejections}"

