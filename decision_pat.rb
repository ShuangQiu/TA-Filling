def patternRead(f)
  pat = f.gets.split("'b")[1].split(";")[0]
  p pat
end

f = open("data/pattern.v","r")

while line=f.gets
  patternRead(f) if line[0..6]=="pattern"
end
