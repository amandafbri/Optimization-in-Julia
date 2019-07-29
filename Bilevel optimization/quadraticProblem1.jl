#QP1

using JuMP, Ipopt
include("setProblem.jl")

model = Model(with_optimizer(Ipopt.Optimizer, print_level = 0, max_iter = 200))

@variable(model, Um[1:nM,0:nT-1] >=0);
@variable(model, Xm[1:nM,1:nX,0:nT]);

#Objetivo
Objective = 0;
for m=1:nM
    for t=1:nT
        for i=1:nX
            @objective(model, Min, Objective = Objective + ((Xm[i,m,t]')*Xm[i,m,t]));
        end
    end
end

for m=1:nM
    for t=0:nT-1
        @objective(model, Min, Objective = Objective + (alpha*((Um[m,t]')*Um[m,t])));
    end
end

#Estado inicial
for m=1:nM
    for i=1:nX
            @constraint(model, Xm[m,i,0] == Xm0);
    end
end

#Variacao controle
for t=0:nT-1
    for m=1:nM
        @constraint(model, Um[m,t] <= r);
    end
end

# Espaco de estados
for m=1:nM
    for t=0:nT-1
        for i=1:nX
            @constraint(model, Xm[m,i,t+1] == sum{Am[m][i,j] * Xm[m,j,t],j=1:nX} + sum{Bm[m][i,j] * Um[m,t],j=1:nU});
        end
    end
end

status = solve(model)

println("Valor da funcao objetivo: ", getobjectivevalue(model))
println("Variaveis de decisao: ",getvalue(Xm), getvalue(Um))
