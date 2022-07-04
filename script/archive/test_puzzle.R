## Call UTS for alumni access: 95142222 option 1, student number required

methods = list()
methods$initialize = function(w, h){
  size <<- list(w = w, h = h)
  reset()
}

methods$start = function(){
  new = 0
  while((loc$i + dir$i <= size$h) & (loc$i + dir$i >= 1) & (loc$j + dir$j <= size$w) & (loc$j + dir$j >= 1)){
    loc$i <<- loc$i + dir$i
    loc$j <<- loc$j + dir$j
    if(box[loc$i, loc$j] == 0){new = new + 1}
    box[loc$i, loc$j] <<- 1
  }
  if((loc$i == size$h) | (loc$i == 1)){dir$i <<- - dir$i}
  if((loc$j == size$w) | (loc$j == 1)){dir$j <<- - dir$j}
  return(new)
}

methods$run = function(){  
  new = 1
  while (new > 0) {new = start()}
}

methods$reset = function(){
  box    <<- matrix(0, nrow = size$h, ncol = size$w)
  loc    <<- list(i = 1, j = 1)
  dir    <<- list(i = 1, j = 1)
  box[1,1] <<- 1
}

Puzzle = setRefClass('Puzzle', fields = list(box = 'matrix', dir = 'list', size = 'list', loc = 'list'), methods = methods)

# Greatest Common Divisor:
gcd <- function(x,y) {
  r <- x%%y;
  return(ifelse(r, gcd(y, r), y))
}

##########

a = Puzzle(23, 35) 
a$run()
sum(a$box)

N = 23
M = 2*(1:50) + 1
res = c()
for(n in N){
  for(m in M){
    a = Puzzle(m, n)
    a$run()
    res = c(res, sum(a$box))
  }
}
names(res) <- paste('N', N, 'M', M)


res[which(gcd(M-1, N-1) == 2)]



res*2/N

res*2/(N*gcd(M-1, N-1))
