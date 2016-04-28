require 'pry'

MTU = 1500
k = 20
clients_current_frame = []
k.times do 
  clients_current_frame << 0
end
current_client = 0
frames = []
f = File.open("data/Terse_silence.dat") or die "Unable to open file..."
f.each_line do |line|
  frames << line.gsub("\n",'')
end

number_of_packets = 0

frames.map! do |frame|
  (frame.to_f/MTU).ceil
end

number_of_packets = frames.inject(0){|sum,x| sum + x }

n=0
t=0.0
arrival_time = 0.0
departure_time = 0.0
client_arrival_time = 0.5

total_messages = 0

c=0
b=0.0
last_time=0.0
dt=0.0
s=0.0

# SETUP
lambda = 7
velocity_of_bandwidth = 0.000222
max_capacity = 200

rejected_messages = 0
minimum_frame_per_second = 24
requests = 0
 
while (t < 100)
  # puts t
  # puts "#{arrival_time}, #{dieeparture_time}"
  if (t > client_arrival_time)
    client_arrival_time += 0.5
    # clients_current_frame << 0
  else
    if (arrival_time<=departure_time)
      total_messages += 1
      if n+(frames[clients_current_frame[current_client]]) <= max_capacity
        t=arrival_time
        dt=t-last_time
        s=s+n*dt
        n=n+(frames[clients_current_frame[current_client]])
        frames[clients_current_frame[current_client]].times do
          print '.'
        end
        last_time=t
        z= 0.001
        arrival_time=t+z
        if (n==1)
          z= 0.000222
          b=b+z
          departure_time=t+z
        end
        if clients_current_frame[current_client] >= number_of_packets
          clients_current_frame.delete_at(current_client)
        else
          clients_current_frame[current_client] += 1
          current_client = (current_client + 1) % clients_current_frame.size
        end
      else
        rejected_messages += 1
        z= 0.001
        arrival_time=t+z
      end
    else
      print "*"
      t=departure_time
      z= 0.000222
      if (n > 0)
        c=c+1
        dt=t-last_time
        n=n-1
        if (n==0) 
          departure_time=1000000
        end
        s=s+n*dt
        last_time=t
        b=b+z
      end
      departure_time=t+z
    end
  end
end

if b > t
  b = t
end

p_of_rejections = rejected_messages / total_messages

x_nurx = c/t
u_nurx = b/t
n_nurx = s/t
r_nurx = n_nurx/x_nurx

puts "\n"
puts "Total time of simulation : #{t}"
puts "Completed messages       : #{c} " 
puts "Requests                 : #{total_messages}"
puts "Clients subscribed       : #{clients_current_frame.size}"
# puts "arrival packets/second   : #{lambda}"
# puts "departure packets/second : #{miu}"
# puts "max capacity             : #{max_capacity}"
# puts "message size             : #{size}"
puts "N                        : #{n_nurx}"
puts "U                        : #{u_nurx}"
puts "R                        : #{r_nurx}"
puts "X                        : #{x_nurx}"
puts "Messages rejected        : #{rejected_messages}"
puts "probability(reject)      : #{p_of_rejections}"

