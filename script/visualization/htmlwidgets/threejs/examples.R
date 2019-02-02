### threejs.R -------------------------

library(threejs)

# Example 1: scatter 3D:
z <- seq(-10, 10, 0.1)
x <- cos(z)
y <- sin(z)
scatterplot3js(x, y, z, color=rainbow(length(z)))

# Example 2: # Example 2:

data(ego)
graphjs(ego, bg="black")

# Example 3: 

library(threejs)
data(LeMis)
N  <- length(V(LeMis))

# Vertex page rank values
pr <- page_rank(LeMis)$vector
# order the page rank values
i <- order(pr, decreasing=TRUE)

# Vertex cluster membership
cl <- unclass(membership(cluster_louvain(LeMis)))

# Find the index of the highest page rank vertex in each cluster
idx <- aggregate(seq(1:N)[i], by=list(cl[i]), FUN=head, 1)$x
# Create a default force-directed layout for the whole network
l1 <- norm_coords(layout_with_fr(LeMis, dim=3))
# Collapse the layout to just the idx vertices
l0 <- Reduce(rbind,Map(function(i) l1[idx[i],], cl))

# Grouped vertex colors, setting all but idx vertices transparent
col <- rainbow(length(idx), alpha=0)[cl]
col[idx] <- rainbow(length(idx), alpha=1)

click <- Map(function(i)
{
  x <- l0
  x[cl == i, ] <- l1[cl == i, ]
  c <- col
  c[cl == i] <- rainbow(length(idx), alpha=1)[i]
  list(layout=x, vertex.color=c)
}, seq(idx))
names(click) <- paste(idx)

graphjs(LeMis, layout=l0, click=click, vertex.color=col, fps=20, font.main="78px Arial")


