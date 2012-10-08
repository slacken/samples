arr = []

1.upto(100){ |i|
  Thread.new{
    c = i
    arr.push(c+1)
  }
  print '.'
}

puts arr