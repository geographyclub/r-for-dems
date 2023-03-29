library("cptcity")
library("plot3Drgl")
library("raster")
library("rpostgis")
library("sf")

db <- dbConnect(dbDriver("PostgreSQL"), user = 'steve', dbname = 'world')
countries <- pgGetGeom(db, c("public", "ne_10m_admin_0_countries_lakes"), geom = "geom", gid = "fid", query=NULL)

dem <- raster('topo15_4320.tif')
dem <- setMinMax(dem)
mask <- countries[countries$name == "Brazil",]
dem <- mask(dem, mask)
dem <- crop(dem, countries[countries$name == "Brazil",])

x <- seq(dem@extent@xmin, dem@extent@xmax, length.out=dem@nrows)
y <- seq(dem@extent@ymin, dem@extent@ymax, length.out=dem@ncols)
z <- matrix(dem, nrow=dem@nrows, ncol=dem@ncols, byrow=TRUE)
z[which(z == 0)] <- NA

col <- colorRampPalette(cpt(n=100, pal='ncl_topo_15lev'))

r3dDefaults$windowRect <- c(50,50, 700, 700)
expand = 0.005
resfac = 0.1

file = paste("topo_brazil_persp3d_", system('date +%Y%m%d%H%M%S', intern=TRUE) ,".png", sep="")
png(file, bg='transparent')
persp3D(x, y, z, bty='n', colkey=FALSE, resfac=resfac, expand=expand, scale=FALSE, facets=TRUE, curtain=FALSE, lighting=FALSE, smooth=FALSE, inttype=2, breaks=NULL, colvar=z, NAcol=NA, col=col(100), border='black', lwd=0.1, alpha=1, shade=0, lphi=-135, ltheta=0, add=FALSE, plot=TRUE)
plotdev(theta=70, phi=70)
dev.off()
