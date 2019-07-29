#QP2
# Julia v1.1.0 & JuMP v0.19

using JuMP, Ipopt, Plots
include("setProblem.jl")

model = Model(with_optimizer(Ipopt.Optimizer, tol = 1e-6, max_iter = 500,output_file="dados2.txt"))
#model = Model(with_optimizer(Gurobi.Optimizer, OutputFlag = 0, OptimalityTol = 1e-6 , IterationLimit = 200))

@variable(model, Um[1:nM,0:nU,0:nT-1]);
@variable(model, Xm[1:nM,1:nX,0:nT]);
@variable(model, Sm[1:nM,0:nT-1] >=0);
@variable(model, Ym[1:nM,1:nY,0:nT]);
@variable(model, Du[1:nM,0:nU,0:nT-1]>=0);

#Objetivo
# @objective(model, Min, sum(((Ym[m,i,t]')*Ym[m,i,t]) for m=1:nM for i=1:nY for t=1:nT) +
#                         (alpha*sum(((Um[m,i,t]')*Um[m,i,t]) for m=1:nM for i=1:nU for t=0))+
#                         (alpha*sum(((Um[m,i,t])-(Um[m,i,t-1]))'*((Um[m,i,t])-(Um[m,i,t-1])) for m=1:nM for i=1:nU for t=1:nT-1)));
@objective(model, Min, sum(((Ym[m,i,t]')*Ym[m,i,t]) for m=1:nM for i=1:nY for t=1:nT) +
                        (alpha*sum(((Du[m,i,t]')*Du[m,i,t]) for m=1:nM for i=1:nU for t=1:nT-1)));

constr = [];
#Estado inicial
for m=1:nM
    for i=1:nX
        @constraint(model, Xm[m,i,0] == Xm0[m,1][i]);
    end
end

#Variacao controle
for i=1:nU
    for m=1:nM
        @constraint(model, Du[m,i,1] == Um[m,i,1] - Um[m,i,0]);
    end
end

for t=1:nT-1
    for i=1:nU
        for m=1:nM
            @constraint(model, Du[m,i,t] == Um[m,i,t] - Um[m,i,t-1]);
        end
    end
end

for t=0:nT-1
    for m=1:nM
        for i=0:nU
            @constraint(model, Um[m,i,t] <= Sm[m,t]);
        end
    end
end

# Espaco de estados
for t=0:nT-1
    for m=1:nM
        for i=1:nX
            @constraint(model, Xm[m,i,t+1] == sum(Am[m][i,j] * Xm[m,j,t] for j=1:nX) + sum(Bm[m][i,j] * Um[m,j,t] for j=1:nU)); #com j=1:nU-1 tb funciona
        end
    end
end

for t=0:nT-1
    for m=1:nM
        for i=1:nY
            @constraint(model, Ym[m,i,t+1] == sum(Cm[m][i,j] * Xm[m,j,t] for j=1:nX) + sum(Dm[m][i,j] * Um[m,j,t] for j=1:nU)); #com j=1:nU-1 tb funciona
        end
    end
end

for t=0:nT-1
    for m=1:nM
        for i=1:nY
            @constraint(model, y_min <= Ym[m,i,t] <= y_max);
        end
    end
end

for t=0:nT-1
    for m=1:nM
        for i=1:nU
            @constraint(model, u_min[m,i] <= Um[m,i,t] <= u_max[m,i]);
        end
    end
end

for t=0:nT-1
    for m=1:nM
        for i=1:nU
            @constraint(model, Du_min[m,i] <= Du[m,i,t] <= Du_max[m,i]);
        end
    end
end

for t=0:nT-1
    @constraint(model, sum(Sm[m,t] for m=1:nM) <= r);
end

@time begin
    JuMP.optimize!.(model);
end

println(JuMP.objective_value(model))
