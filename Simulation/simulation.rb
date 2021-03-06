require 'pry'
require 'gruff'

generate_graphs = true
# MAX TRANSFER UNIT
MTU = 1500
# VARIABLES FOR THE EXCERCISES
puts "Enter max capacity: "
max_capacity = gets.chomp.to_i
puts "Enter number of initial clients: "
k = gets.chomp.to_i
############################# Initial clients ##################################

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
dat_file_name = "Terse_Jurassic"
f = File.open("data/#{dat_file_name}.dat") or die "Unable to open file..."

# RANDOM INITIAL FRAME
# initial_frame = initial_delay = rand(10000..50000)
# STATIC INITIAL FRAME
initial_frame = initial_delay = 10000
aux = 0
# creates an array of frames using an offset of 10000
# it contains the frame size of 2000 frames
f.each_line do |line|
  if aux > initial_frame + 2000
    break
  elsif aux > initial_frame
    frames << line.gsub("\n",'')
  end
  aux += 1
end

# change the array from size of each frame to packets for each frame
frames.map! do |frame|
  (frame.to_f / MTU).ceil
end 

f.close

# number_of_packets = frames.inject(0){|sum,x| sum + x }

########################### GENERATE DELAYS ####################################

# read data/amazon_delays.dat that contains the delay for each frame
delays = []
f = File.open("data/amazon_delays.dat") or die "Unable to open file..."


# create an array of delays using the same offset of the frames
aux = 0
f.each_line do |line|
  if aux > initial_delay + 2000
    break
  elsif aux > initial_delay
    delays << line.gsub("\n",'').to_f / 1000000
  end
  aux += 1
end

f.close

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
completed_packets = 0
# Busy time
b = 0.0
# Last time (helper for busy time)
last_time = 0.0

#area
dt = 0.0
s = 0.0

# SETUP
velocity_of_bandwidth = 0.000222
velocity_of_arrival = 0.001

# variables needed for data extraction
rejected_requests = 0
errors_at_sending = 0
clients_finished = 0
max_clients_in_system = 0
min_clients_in_system = k
max_packets_in_queue = 0
delayed_time = 0.0
buffer_full = false
buffer_full_time = 0.0
buffer_full_initial_time = 0.0
buffer_empty = false
buffer_empty_time = 0.0
buffer_empty_initial_time = 0.0

# variables for graphs
buffer_for_graph = []
clients_for_graph = []
errors_for_graph = []
delayed_time_for_graph = []
clients_finished_for_graph = []
buffer_full_time_for_graph = []
times_count = 0

 
while (t < 1000)
  # update max packets in the queue
  if max_packets_in_queue < n
    max_packets_in_queue = n
  end
  # if there are no more clients it ends the simulation
  if clients_current_frame.size == 0
    break
  else
    if generate_graphs
      if times_count % 10 == 0
        buffer_for_graph << n
        clients_for_graph << clients_current_frame.size
        errors_for_graph << errors_at_sending
        clients_finished_for_graph << clients_finished
        delayed_time_for_graph << delayed_time
        buffer_full_time_for_graph << buffer_full_time
      end
      times_count += 1
    end
    if (t > client_arrival_time)
      # new arrival time of a client
      client_arrival_time += clients_rate
      # ENABLE DYNAMIC CLIENTS if comment this line, there will be no new
      # clients
      clients_current_frame << 0
      # updates max and min clients on th system
      if max_clients_in_system < clients_current_frame.size
        max_clients_in_system = clients_current_frame.size
      end
      if min_clients_in_system > clients_current_frame.size
        min_clients_in_system = clients_current_frame.size
      end
    else
      # Choose betwen an arrival or a departure
      if (arrival_time <= departure_time)
        # Update total messages
        total_messages += 1
        # If packets will fit in buffer put them in it
        if n + (frames[clients_current_frame[current_client]]) <= max_capacity
          # end buffer empty event
          if (buffer_empty)
            buffer_empty = false
            buffer_empty_time += t - buffer_empty_initial_time
          end
          delayed_time += (delays[clients_current_frame[current_client]])
          # update time
          t = arrival_time
          # update area
          dt = t - last_time
          s = s + n * dt
          # Add packets to buffer
          n = n + (frames[clients_current_frame[current_client]])
          # update last time
          last_time = t
          # new arrival time
          z = velocity_of_arrival
          arrival_time = t + z
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
          z = velocity_of_arrival
          # start buffer full event
          if !buffer_full
            buffer_full = true
            buffer_full_initial_time = t
          end
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
          s = s + n * dt
          last_time = t
          n = n - 1
          b = b + z
          if (n==0)
            # start buffer empty event
            if ! buffer_empty
              buffer_empty = true
              buffer_empty_initial_time = t
            end
            departure_time = 1000000
          end
        end
        # update departure time
        departure_time= t + z
        # compute buffer full time
        if buffer_full
          buffer_full = false
          buffer_full_time += t - buffer_full_initial_time
        end
      end
    end
  end
end

if b > t
  b = t
end

p_of_rejections = rejected_requests / total_messages.to_f

completed_requests = (clients_finished * 2000) + clients_current_frame.inject(0){|sum,x| sum + x }
x_nurx_r = (completed_requests*frames.inject(0){|sum,x| sum + x } / 2000.0)/t
x_nurx_p = completed_packets/t
u_nurx = b/t
n_nurx = s/t
r_nurx = n_nurx/x_nurx_p

puts "\n"
puts "Average of packets per frame    : #{frames.inject(0){|sum,x| sum + x } / 2000.0}"
puts "Total Requests                  : #{total_messages}"
puts "Total time of simulation        : #{t.round(8)}"
puts "Completed packages              : #{completed_packets}" 
puts "Errors at sending               : #{errors_at_sending}"
puts "Initial clients                 : #{k}"
puts "Clients subscribed(final)       : #{clients_current_frame.size}"
puts "Clients finished                : #{clients_finished}"
puts "Max clients on system           : #{max_clients_in_system}"
puts "Min clients on system           : #{min_clients_in_system}"
puts "Max packets on queue            : #{max_packets_in_queue}"
puts "N                               : #{n_nurx.round(8)}"
puts "U                               : #{u_nurx.round(8)}"
puts "R                               : #{r_nurx.round(8)}"
puts "X (requests)                    : #{x_nurx_r.round(8)}"
puts "X (packets)                     : #{x_nurx_p.round(8)}"
puts "Message Requests rejected       : #{rejected_requests}"
puts "Probability(reject of buffer)   : #{"%.8f" % p_of_rejections.round(8)}"
puts "Total delay time                : #{delayed_time.round(8)}"
puts "Total buffer full time          : #{buffer_full_time.round(8)}"
puts "Buffer full time %              : #{"%.8f" % (buffer_full_time/t).round(8)}"
puts "Total buffer empty time         : #{buffer_empty_time.round(8)}"
puts "Buffer empty time %             : #{"%.8f" % (buffer_empty_time/t).round(8)}"


################################## GRAPHS ######################################
if generate_graphs
  puts "\n GENERATING GRAPHS, THIS COULD TAKE A WHILE \n"
  label_distance = (buffer_for_graph.size / 10).floor
  labels = {}
  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10].each do |label|
    labels[label*label_distance] = (label * 100).to_s
  end

  ########################
  ### buffer over time ###
  ########################
  g = Gruff::Line.new
  g.title = 'Packets in buffer'
  g.labels = labels
  g.y_axis_label = '# of packets'
  g.x_axis_label = 'Seconds'
  g.data :Packets, buffer_for_graph
  g.write("graphs/#{dat_file_name}_packets_in_buffer.png")
  print "."

  #########################
  ### clients over time ###
  #########################
  g = Gruff::Line.new
  g.title = 'Clients in system'
  g.labels = labels
  g.y_axis_label = '# of clients'
  g.x_axis_label = 'Seconds'
  g.data :Clients, clients_for_graph
  g.write("graphs/#{dat_file_name}_clients_in_system.png")
  print "."

  #########################
  ### errors over time ###
  #########################
  g = Gruff::Line.new
  g.title = 'Errors at sending'
  g.labels = labels
  g.y_axis_label = '# of errors'
  g.x_axis_label = 'Seconds'
  g.data :Errors, errors_for_graph
  g.write("graphs/#{dat_file_name}_errors_at_sending.png")
  print "."

  #######################
  ### delay over time ###
  #######################
  g = Gruff::Line.new
  g.title = 'Delay of cloud (seconds)'
  g.labels = labels
  g.y_axis_label = 'Seconds'
  g.x_axis_label = 'Seconds'
  g.data :Delay, delayed_time_for_graph
  g.write("graphs/#{dat_file_name}_delay_of_cloud.png")
  print "."

  #######################
  ### clients finished over time ###
  #######################
  g = Gruff::Line.new
  g.title = 'Clients finished'
  g.labels = labels
  g.y_axis_label = '# of clients'
  g.x_axis_label = 'Seconds'
  g.data :Clients, clients_finished_for_graph
  g.write("graphs/#{dat_file_name}_clients_finished.png")
  print "."

  g = Gruff::Line.new
  g.title = 'Buffer full time'
  g.labels = labels
  g.y_axis_label = 'Seconds'
  g.x_axis_label = 'Seconds'
  g.data :Time, buffer_full_time_for_graph
  g.write("graphs/#{dat_file_name}_buffer_full_time.png")
  print "."

  print "\n"
end

################################################################################
