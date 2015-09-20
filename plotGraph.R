plotGraph <- function(G,d){
	plot(G,vertex.label=NA,edge.width=E(G)$weight,vertex.size=d/20,layout=layout.kamada.kawai)
}