# Julia v1.1.0 & JuMP v0.19

# Opcao de paralelizacao
# using Distributed
# @everywhere using JuMP, Ipopt, Gurobi, DistributedArrays
#
# @everywhere include("setProblem.jl")
# @everywhere include("slave.jl")

using JuMP, Ipopt, Gurobi
include("setProblem.jl")
include("slave.jl")

model_master = Model(with_optimizer(Ipopt.Optimizer, tol = 1e-6, max_iter = 500))

tempo_sub = 0;

function subProblem(x...)
    global grad, S, tempo_sub
    tempo = @elapsed s, grad, sm, S= slave(x)
    tempo_sub += tempo
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

@variable(model_master, Smaster[1:nM,0:nT-1] >= 0);

for t=0:nT-1
    @constraint(model_master, sum(Smaster[m,t] for m=1:nM) <= r);
end

d = nM*(nT);
JuMP.register(model_master, :custo, d, custo, deltacusto, autodiff=false)
@NLobjective(model_master, Min, custo(Smaster...))

tempo_total = @elapsed JuMP.optimize!.(model_master);

println(JuMP.objective_value(model_master))
println("The sub time value is: ", tempo_sub)
println("The master time value is: ", tempo_total - tempo_sub)
println("The total time value is: ", tempo_total)
