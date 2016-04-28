require 'pry'

frames = []
f = File.open("data/Terse_Jurassic.dat") or die "Unable to open file..."
f.each_line do |line|
  frames << line.gsub("\n",'')
end

number_of_packets = 0

frames.each do |frame|
  number_of_packets += (frame.to_f/1500).ceil
end
# binding.pry

fin=1000

n=0
t=0
arrival_time=0
departure_time=10

total_messages = 0

c=0
b=0
last_time=0
dt=0
s=0

# SETUP
MTU = 1500
lambda = 7
velocity_of_bandwidth = 0.000222
max_capacity = 37

rejected_messages = 0
q_frames = frames.size
minimum_frame_per_second = 24

while (c<q_frames)
  if (arrival_time<=departure_time)
    total_messages += 1
    if n < max_capacity
      t=arrival_time
      dt=t-last_time
      s=s+n*dt
      n=n+1
      last_time=t
      z= 0.001
      arrival_time=t+z
      # printf("%f n=%i Arr arrival_time=%f\n",t,n,arrival_time)
      if (n==1)
        z= 0.000222
        b=b+z
        departure_time=t+z
        # printf("%f n=%i DEP Arr departure_time=%f\n",t,n,departure_time)
      end
    else
      rejected_messages += 1
      z= 0.001
      arrival_time=t+z
    end
  else 
    c=c+1
    t=departure_time
    dt=t-last_time
    n=n-1
    if (n==0) 
      departure_time=1000000
    end
    s=s+n*dt
    last_time=t
    if (n>=1)
      z= 0.000222
      b=b+z
      departure_time=t+z
      # printf("%f n=%i Dep\n",t,n)
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
# puts "arrival packets/second   : #{lambda}"
# puts "departure packets/second : #{miu}"
# puts "max capacity             : #{max_capacity}"
# puts "message size             : #{size}"
puts "N                        : #{n_nurx}"
puts "U                        : #{u_nurx}"
puts "R                        : #{r_nurx}"
puts "X                        : #{x_nurx}"
# puts "Messages rejected        : #{rejected_messages}"
# puts "probability(reject)      : #{p_of_rejections}"