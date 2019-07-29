using Random

Random.seed!(1)

#Parâmetros variantes
nM = 2
nT = 5

nX = 2
nU = 2
nY = 1

alpha = 5
r = 0.25

#Modifica para 7 e -7, respectivamente, quando M = 20 e T = 8
y_max = 5
y_min = -5

u_max = 3*ones(nM,nU)
u_min = zeros(nM,nU)

Du_max = 3*ones(nM,nU)
Du_min = -3*ones(nM,nU)

Am = [];
Bm = [];
Cm = [];
Dm = [];
Xm0 = [];
for m=1:nM
       push!(Am,rand(nX,nX));
       push!(Bm,rand(nX,nU));
       push!(Cm,rand(nY,nX));
       push!(Dm,zeros(nY,nU));
       push!(Xm0,rand(nX));
end

# Geração do problema com paralelismo
# u_max = 3*dones(nM,nU)
# u_min = dzeros(nM,nU)
#
# Du_max = 3*dones(nM,nU)
# Du_min = -3*dones(nM,nU)
#
# Am = [];
# Bm = [];
# Cm = [];
# Dm = [];
# Xm0 = [];
# for m=1:nM
#        push!(Am,drand(nX,nX));
#        push!(Bm,drand(nX,nU));
#        push!(Cm,drand(nY,nX));
#        push!(Dm,dzeros(nY,nU));
#        push!(Xm0,drand(nX));
# end
