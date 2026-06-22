########################################################################################
########################################################################################
###          Network Analysis of the French interpretation of the Interpersonal      ###
###                        Reactivity Index in 1973 normal subjects                  ###
###              Briganti G, Kempenaers C, Braun S, Fried EI, Linkowski P            ### 
###         Email = giovanni.briganti@hotmail.com    twitter= @giovbriganti          ###
########################################################################################
########################################################################################


library(qgraph)
library(stats)
library(readr)
library(bootnet)
library(igraph)
library(dplyr)
library(mgm)
library(reshape2)
library(data.table)
library(ggplot2) 



#for data users = load the data (modify the file path in the command)
prep <- read.csv("iri_analysis_ready.csv", stringsAsFactors = FALSE)
node_labels <- setdiff(names(prep), c("gender", "age"))   # 28 items, Davis order
data <- prep[, node_labels]
colnames(data) <- 1:28    

#correlation matrix
cor_davis <- cor(data, method="spearman")

#names
names<- c("1FS", "2EC", "3PT_R", "4EC_R", "5FS", "6PD", "7FS_R", 
          "8PT","9EC", "10PD", "11PT", "12FS_R", "13PD_R", "14EC_R", "15PT_R", 
          "16FS", "17PD", "18EC_R", "19PD_R", "20EC", "21PT", "22EC", "23FS", 
          "24PD", "25PT", "26FS", "27PD", "28PT")

#groups
gr <- list(c(1, 5, 7, 12, 16, 23, 26), c(3, 8, 11, 15, 21, 25, 28),
           c(2, 4, 9, 14, 18, 20, 22), c(6, 10, 13, 17, 19, 24, 27))

# estimate gaussian graphical model using spearman correlations
network1 <- estimateNetwork(data, default="EBICglasso", corMethod = "cor", corArgs =
                              list(method = "spearman", use = "pairwise.complete.obs"))
#node predictability
type=rep('g', 28) #g=gaussian, 28 = number of nodes in the network
fit1<-mgm(as.matrix(data),
          type=type, 
          level=rep(1,28))
pred1<- predict(fit1, as.matrix(data))
pred1$error
mean(pred1$error$R2) #shows the mean predictability of a node in the network 

#visualize network with original data
graph1 <- plot(network1,labels = TRUE, nodeNames=names, pie = pred1$error$R2, 
               layout="spring", groups=gr, color=c("#d7191c", "#fdae61", "#abd9e9", "#2c7bb6"), 
               legend.cex=.35)
pdf("Figure1.pdf", width=10, height=7)
qgraph(graph1)
dev.off()

#graph1 weight matrix
graph1mat <- getWmat(graph1)
graph1mat #visualize weight matrix

#mean graph1 weight matrix
mean(graph1mat) #visualize the mean edge weight of the network = 0.025

#spinglass algorithm
#run the spinglass algorithm 100 times to get a mean of communities, max and min values
g = as.igraph(graph1, attributes=TRUE)
E(g)$weight <- abs(E(g)$weight) 
matrix_spinglass <- matrix(NA, nrow=1,ncol=100)
for (i in 1:100) {
  set.seed(i)
  spinglass <- cluster_spinglass(g)     
  matrix_spinglass[1,i] <- max(spinglass$membership) 
}
mean(as.vector(matrix_spinglass)) 
max(as.vector(matrix_spinglass)) 
min(as.vector(matrix_spinglass)) 
median(as.vector(matrix_spinglass)) 
set.seed(1) 
sgc <- cluster_spinglass(g)    
sgc$membership #shows the membership of an item to a community

#walktrap algorithm
glasso.ebic <-EBICglasso(S=cor_davis, n = nrow(data)) #build a graph object for the algorithm
graph.glasso <-as.igraph(qgraph(glasso.ebic, layout = "spring", vsize = 3))
E(graph.glasso)$weight <- abs(E(graph.glasso)$weight) 
wc<- cluster_walktrap(graph.glasso)  
n.dim <- max(wc$membership)  

#eigenvalue plot
plot(eigen(cor_davis)$values, type="b")
abline(h=1,col="red", lty = 3)

#Fig.2 Davis Network centrality plot, in the Supplementary Materials
graph1_cp <- centralityPlot(graph1) #using the graph from the data
pdf("Figure2bis.pdf", width=10, height=7) 
print(graph1_cp) 
dev.off()

#centrality criteria 
graph1.c <- centrality(graph1)
graph1.c$InDegree
graph1.c$Closeness
graph1.c$Betweenness 
cor(graph1.c$InDegree, graph1.c$Betweenness, method = "spearman") 
cor(graph1.c$InDegree, graph1.c$Closeness, method = "spearman") 
cor(graph1.c$Closeness, graph1.c$Betweenness, method = "spearman") 

cent <- as.data.frame(scale(centrality(graph1)$InDegree))
cent <- mutate(cent, id = rownames(cent))
colnames(cent) <- c("1", "IRI_Item")
cent_long <- reshape2::melt(cent, id.vars = "IRI_Item") 

pdf("Figure2.pdf", width=6, height=4, useDingbats=FALSE)
strengthplot <- ggplot(data=cent_long, aes(x=IRI_Item, y=value, group=1)) +
  geom_line() +
  geom_point(shape = 21, fill = "white", size = 1.5, stroke = 1) +
  xlab(" ") + ylab("Centrality") +
  scale_y_continuous(limits = c(-3, 3)) + 
  scale_x_discrete(limits=c(1:28)) +
  theme_bw() +
  theme(panel.grid.minor=element_blank(), axis.text.x = element_text(angle = 45, hjust = 1))
strengthplot
# coord_flip()
dev.off()

# stabilility
set.seed(1)
boot1 <- bootnet(network1, nCores=7, nBoots=2000,
                 statistics = c("edge", "strength", "closeness", "betweenness"))  
set.seed(1)
boot2 <- bootnet(network1, nCores=7, nBoots=2000, type="case",
                 statistics = c("edge", "strength", "closeness", "betweenness")) 
save(boot1, file = "boot1davis.Rdata")
save(boot2, file = "boot2davis.Rdata")


# Fig3 - Edge weight bootstrap
fig3 <- plot(boot1, labels = FALSE, order = "sample")
pdf("Figure3.pdf", width=10, height=7) 
plot(boot1, labels = FALSE, order = "sample") 
dev.off()

#Fig3 - Edge weight difference: is edge X significantly larger than edge Y? Black=Y Gray=N 
boot3 <- plot(boot1, "edge", plot = "difference", onlyNonZero = TRUE, order = "sample")
plot(boot3)
pdf("Figure4.pdf", width=10, height=7)
plot(boot3)
dev.off()

#Fig5 - Centrality Bootstrap
plot(boot2)
cs1 <- corStability(boot2)  
pdf("Figure5.pdf", width=10, height=7)
plot(boot2)
dev.off()

#Fig6 - Centrality difference: is node X significantly more central than node Y? Black=Yes, Gray=N
boot4 <- plot(boot1, "strength", order="sample", labels=TRUE) 
pdf("Figure6.pdf", width=10, height=7)
plot(boot4) 
dev.off()



