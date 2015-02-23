require "./models"

a = Audio.get(28)
input = a.source.path
output = File.dirname(input)
`./windDet -i #{input} -o #{output}/output`