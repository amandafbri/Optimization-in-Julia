#Subproblem Benders

#vai retornar o mesmo de antes + upper (coloquei igual "s", mas tem que conferir)

function SubFactivel(s)
    model = Model(with_optimizer(Ipopt.Optimizer, print_level = 0, max_iter = 200))

    @variable(model, Um[1:nM,0:nU,0:nT-1]>=0);
    @variable(model, Xm[1:nM,1:nX,0:nT]);
    @variable(model, Sm[1:nM,0:nT-1] >=0);

    #Objetivo
    @objective(model, Min, sum(((Xm[m,i,t]')*Xm[m,i,t]) for m=1:nM for i=1:nX for t=1:nT) + (alpha*sum(((Um[m,i,t]')*Um[m,i,t]) for m=1:nM for i=1:nU for t=0:nT-1)));

    constr = [];
    #Estado inicial
    for m=1:nM
        for i=1:nX
                constr = (constr,@constraint(model, Xm[m,i,0] == Xm0));
        end
    end

    #Variacao controle
    for t=0:nT-1
        for m=1:nM
            for i=0:nU
                constr = (constr,@constraint(model, Um[m,i,t] <= Sm[m,t]));
            end
        end
    end

    # Espaco de estados
    for t=0:nT-1
        for m=1:nM
            for i=1:nX
                constr = (constr,@constraint(model, Xm[m,i,t+1] == sum(Am[m][i,j] * Xm[m,j,t] for j=1:nX) + sum(Bm[m][i,j] * Um[m,j,t] for j=1:nU))); #com j=1:nU-1 tb funciona
            end
        end
    end

    solm = JuMP.optimize!.(model);
    sm = JuMP.objective_value(model);
    S = (Xm = JuMP.value.(Xm), Um = JuMP.value.(Um));

    s = sum(sm)

#A ser verificado, pois nao estava conseguindo fazer de outro jeito
    sConstraints = length(constr);

    it = sConstraints - (nU-1);
    sens = zeros(1, nU-1);

    let it = it
        for t=1:nU-1
             for r=1:1
                it = it + 1
                sens[r,t] = JuMP.dual(constr[it]);
             end
        end
    end

    Ub = s;

    #pra dizer que deu factivel ou nao
    if solm == :Optimal
        flg = 0
    else
        flg = 1
    end

    return s, sens, sm, S, Ub
    #s, grad, sm, Sm
end
