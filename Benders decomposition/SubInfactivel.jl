#Subproblem Benders

#retorna o mesmo de antes + upper + corte

function SubInfactivel(s)
    model = Model(with_optimizer(Ipopt.Optimizer, print_level = 0, max_iter = 200))

    @variable(model, Um[1:nM,0:nU,0:nT-1]>=0);
    @variable(model, Xm[1:nM,1:nX,0:nT]);
    @variable(model, Sm[1:nM,0:nT-1] >=0);


    solm = JuMP.optimize!.(model);

    

    Ub = s;

    return s, sens, sm, S, Ub, cut

end
