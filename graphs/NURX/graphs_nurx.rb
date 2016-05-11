require 'gruff'

puts "\n GENERATING GRAPHS, THIS COULD TAKE A WHILE \n"
labels = {0 => '50', 1 => '100', 2 => '200', 3 => '500'}
graphs = ['k = 5', 'k = 10', 'k = 15', 'k = 20']
N = {'k = 5' => [1.29612716, 1.34188436, 1.46088417, 1.46088417],
     'k = 10' => [1.37630067, 1.43795684, 1.64724501, 1.72291072],
     'k = 15' => [1.39535197, 1.4815092, 1.7494217, 2.16020144],
     'k = 20' => [1.58424883, 1.69299513, 1.99388367, 2.49521448]} 
U = {'k = 5' => [0.65180841, 0.65181457, 0.65182967, 0.65182967],
     'k = 10' => [0.65186835, 0.6518754, 0.65189363, 0.65191669],
     'k = 15' => [0.65189716, 0.65191092, 0.65193245, 0.65197019],
     'k = 20' => [0.65190715,0.65195691,0.65197663,0.65201215]}
R = {'k = 5' => [0.00029035, 0.0003006, 0.00032726, 0.00032725],
     'k = 10' => [0.00031147, 0.00032541, 0.00037279, 0.00038991],
     'k = 15' => [0.000319, 0.00033866, 0.00039989, 0.00049379],
     'k = 20' => [0.00036605, 0.00039108, 0.00046052, 0.00057636]} 
X = {'k = 5' => [4463.980911, 4464.086509, 4464.031509, 4464.119509],
     'k = 10' => [4418.773876, 4418.924514, 4418.737673, 4418.686514],
     'k = 15' => [4374.094519, 4374.599519, 4374.788519, 4374.779519],
     'k = 20' => [4327.951524, 4329.078758, 4329.618524, 4329.250524]} 

graphs.each do |graph_title|
  g = Gruff::Line.new
  g.title = graph_title
  g.labels = labels
  g.y_axis_label = 'Packets'
  g.x_axis_label = 'Buffer Size'
  g.data :N, N[graph_title]
  g.use_data_label = true
  g.minimum_value = 0
  g.write("#{graph_title.gsub(" ", "_").gsub("=", "equals")}_N.png")
  print '.'

  g = Gruff::Line.new
  g.title = graph_title
  g.labels = labels
  g.y_axis_label = 'Value'
  g.x_axis_label = 'Buffer Size'
  g.data :U, U[graph_title]
  g.minimum_value = 0
  g.use_data_label = true
  g.write("#{graph_title.gsub(" ", "_").gsub("=", "equals")}_U.png")
  print '.'

  g = Gruff::Line.new
  g.title = graph_title
  g.labels = labels
  g.y_axis_label = 'Seconds'
  g.x_axis_label = 'Buffer Size'
  g.data :R, R[graph_title]
  g.minimum_value = 0
  g.use_data_label = true
  g.write("#{graph_title.gsub(" ", "_").gsub("=", "equals")}_r.png")
  print '.'

  g = Gruff::Line.new
  g.title = graph_title
  g.labels = labels
  g.y_axis_label = 'Frames per second'
  g.x_axis_label = 'Buffer Size'
  g.data :X, X[graph_title]
  g.use_data_label = true
  g.minimum_value = 0
  g.write("#{graph_title.gsub(" ", "_").gsub("=", "equals")}_X.png")

  print '.'
end

print "\n"

