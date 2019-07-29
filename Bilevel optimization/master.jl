#Bilevel Master
# Julia v1.1.0 & JuMP v0.19

using JuMP, Ipopt, Gurobi
include("setProblem.jl")
include("slave.jl")
model_master = Model(with_optimizer(Ipopt.Optimizer, tol = 1e-6, max_iter = 500, output_file="dados.txt"))
#model_master = Model(with_optimizer(Ipopt.Optimizer, tol = 1e-6, max_iter = 50))

function subProblem(x...)
    global grad, S
    s, grad, sm, S = slave(x)
    #Sm = S s = sm grad = sens
    #s, grad, sm, Sm
    return sm
end

custo(x...) = subProblem(x...)

function deltacusto(g, x...)
    for i in 1:length(grad)
        g[i]=grad[i]
    end
    return g
end

@variable(model_master, Smaster[1:nM,0:nT-1] >= 0, start=0.125);

for t=0:nT-1
    @constraint(model_master, sum(Smaster[m,t] for m=1:nM) <= r);
end

d = nM*(nT);
JuMP.register(model_master, :custo, d, custo, deltacusto, autodiff=false)
@NLobjective(model_master, Min, custo(Smaster...))
@time begin
    JuMP.optimize!.(model_master);
end

println(JuMP.objective_value(model_master))
