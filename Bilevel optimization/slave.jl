# Julia v1.1.0 & JuMP v0.19

function slave(ex)
# Escolha do solver
  model = Model(with_optimizer(Ipopt.Optimizer, tol = 1e-6, max_iter = 200))
 #model = Model(with_optimizer(Gurobi.Optimizer, OutputFlag = 0, OptimalityTol = 1e-6 ,IterationLimit = 200))

    @variable(model, Um[1:nM,0:nU,0:nT-1]>=0);
    @variable(model, Xm[1:nM,1:nX,0:nT]);
    @variable(model, Sm[1:nM,0:nT-1] >=0);
    @variable(model, Ym[1:nM,1:nY,0:nT]);
    @variable(model, Du[1:nM,0:nU,0:nT-1]);

    # Objetivo
    @objective(model, Min, sum(((Ym[m,i,t]')*Ym[m,i,t]) for m=1:nM for i=1:nY for t=1:nT) + (alpha*sum(((Du[m,i,t]')*Du[m,i,t]) for m=1:nM for i=1:nU for t=1:nT-1)));

    constr = [];
    # Estado inicial
    for m=1:nM
        for i=1:nX
            constr = (constr,@constraint(model, Xm[m,i,0] == Xm0[m,1][i]));
        end
    end

    # Variacao controle
    for i=1:nU
        for m=1:nM
            constr = (constr,@constraint(model, Du[m,i,1] ==
            Um[m,i,1] - Um[m,i,0]));
        end
    end

    for t=1:nT-1
        for i=1:nU
            for m=1:nM
                constr = (constr,@constraint(model, Du[m,i,t] ==
                Um[m,i,t] - Um[m,i,t-1]));
            end
        end
    end

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
                constr = (constr,@constraint(model, Xm[m,i,t+1] ==
                            sum(Am[m][i,j] * Xm[m,j,t] for j=1:nX) +
                            sum(Bm[m][i,j] * Um[m,j,t] for j=1:nU)));
            end
        end
    end

    for t=0:nT-1
        for m=1:nM
            for i=1:nY
                constr = (constr,@constraint(model, Ym[m,i,t+1] ==
                            sum(Cm[m][i,j] * Xm[m,j,t] for j=1:nX) +
                            sum(Dm[m][i,j] * Um[m,j,t] for j=1:nU)));
            end
        end
    end

    # Limites
    for t=0:nT-1
        for m=1:nM
            for i=1:nY
                constr = (constr,@constraint(model,
                            y_min <= Ym[m,i,t] <= y_max));
            end
        end
    end

    for t=0:nT-1
        for m=1:nM
            for i=1:nU
                constr = (constr,@constraint(model,
                            u_min[m,i] <= Um[m,i,t] <= u_max[m,i]));
            end
        end
    end

    for t=0:nT-1
        for m=1:nM
            for i=1:nU
                constr = (constr,@constraint(model,
                            Du_min[m,i] <= Du[m,i,t] <= Du_max[m,i]));
            end
        end
    end

    # Gradiente
    e = zeros(nT-1,nM);
    itt = 1;
    let itt = itt
            for t=1:nT-1
                for m=1:nM
                    e[t,m] = ex[itt];
                    itt = itt+1;
                end
            end
    end

    for m=1:nM
        for t=0:nT-1
            constr = (constr,@constraint(model, (Sm[m,t]-ex[m])==0));
        end
    end

    solm = JuMP.optimize!.(model);
    sm = JuMP.objective_value(model);
    S = (Xm = JuMP.value.(Xm), Ym = JuMP.value.(Ym),
         Um = JuMP.value.(Um), Du = JuMP.value.(Du));

    s = sum(sm)

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

    return s, sens, sm, S
end
