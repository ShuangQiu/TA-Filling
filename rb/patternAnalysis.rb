$currentPat='00000'.split(//)
$diffBit=0

def patternDiff(pat)
  for i in 0..pat.length-1
#    pat[i]=$currentPat[i] if 'X'==pat[i]
    $diffBit+=1 if pat[i]!=$currentPat[i]
  end
end

def patternRead(f)
  pat = f.gets.split("'b")[1].split(";")[0].split(//)
  patternDiff(pat)
end

f = open("../dof/mt_patterns.v","r")

while line=f.gets
  patternRead(f) if line[0..6]=="pattern"
end

p $diffBit
