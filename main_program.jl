using LinearAlgebra
using DataFrames
using CSV

# Se calcula la matriz Bbus
function calcular_bbus(lines,nodes)
    """
    Entradas:   lines: DataFrames
                nodes : DataFrames
    Salida :    Bbus : Matriz
    """
    num_nodes = nrow(nodes)
    num_lines = nrow(lines)
    Bbus = zeros(num_nodes, num_nodes)
    for k = 1:num_lines
        # Nodo de envío
        n1 = lines.FROM[k]
        # Nodo de recibo
        n2 = lines.TO[k]
        # Admitancia de la línea
        BL = 1/(lines.X[k])
        Bbus[n1,n1] += BL        # Dentro de la diagonal
        Bbus[n1,n2] -= BL        # Fuera de la diagonal
        Bbus[n2,n1] -= BL        # Fuera de la diagonal
        Bbus[n2,n2] += BL        # Dentro de la diagonal
    end
    s = nodes[nodes.TYPE .== 3, "NUMBER"]
    Bbus = Bbus[setdiff(1:end, s), setdiff(1:end, s)]
    return Bbus
end

# Calculo de los coeficientes sensibilidad por cambio en la generación.
function calculo_de_α_li(Bbus, lines, nodes)
    """
    Entradas:   Bbus: Matriz de suscetancias del sistema
                lines: DataFrame con los datos de las líneas
                nodes: Dataframe con los datos de los nodos.
    Salida :    alpha: Matriz con los factores de sensibilidad por cambio en la generación.
    """
    # Calculamos la matriz w la cual corresponde a la inversa de la matriz Bbus
    W_ini = try 
        W_ini = inv(Bbus)

    catch
        W_ini = pinv(Bbus)
    end
    # Para añadir ambas
    m, n = size(W_ini)

    W = zeros(m + 1, n + 1)

    # Hallando el nodo slack
    s = only(nodes[nodes.TYPE .== 3, "NUMBER"])

    # Añadiendo las filas y columnas del nodo slack    
    W[1:s-1, 1:s-1] = W_ini[1:s-1, 1:s-1]  # Parte superior izquierda
    W[1:s-1, s+1:end] = W_ini[1:s-1, s:end]  # Parte superior derecha
    W[s+1:end, 1:s-1] = W_ini[s:end, 1:s-1]  # Parte inferior izquierda
    W[s+1:end, s+1:end] = W_ini[s:end, s:end]  # Parte inferior derecha
    
    # Factor de sensibilidad por cambio en la generación.
    num_lines = nrow(lines)
    num_nodes = nrow(nodes)
    alpha = zeros(num_lines,num_nodes)
    for i = 1:num_lines
        k = lines.FROM[i]
        m = lines.TO[i]
        for j = 1:num_nodes
            alpha[i,j] = 1/(lines.X[i])*(W[k,j]-W[m,j])
        end
    end
    return alpha
end

# Calculo de la matriz delta.
function calculo_de_δ_il(Bbus, lines, nodes)
    """
    Entradas:   Bbus: Matriz de suscetancias del sistema
                lines: DataFrame con los datos de las líneas
                nodes: Dataframe con los datos de los nodos.
    Salida :    delta: DataFrame con la matriz Delta.
    """
     # Calculamos la matriz w la cual corresponde a la inversa de la matriz Bbus
     W_ini = try 
        W_ini = inv(Bbus)

    catch
        W_ini = pinv(Bbus)
    end
    # Para añadir ambas
    m, n = size(W_ini)
    W = zeros(m + 1, n + 1)
    # Hallando el nodo slack
    s = only(nodes[nodes.TYPE .== 3, "NUMBER"])

    # Añadiendo las filas y columnas del nodo slack    
    W[1:s-1, 1:s-1] = W_ini[1:s-1, 1:s-1]  # Parte superior izquierda
    W[1:s-1, s+1:end] = W_ini[1:s-1, s:end]  # Parte superior derecha
    W[s+1:end, 1:s-1] = W_ini[s:end, 1:s-1]  # Parte inferior izquierda
    W[s+1:end, s+1:end] = W_ini[s:end, s:end]  # Parte inferior derecha

    # Factores de distribución del corte de la línea.
    num_lines = nrow(lines)
    num_nodes = nrow(nodes)
    delta= zeros(num_nodes,num_lines)
    for i = 1:num_lines
        k = lines.FROM[i]
        m = lines.TO[i]
        for j = 1:num_nodes
            delta[j,i] = (lines.X[i]*(W[j,k]-W[j,m]))/(lines.X[i] - (W[k,k]+W[m,m]-2*W[m,k]))
        end
    end
    return delta
end

# Calculo de los factores de distribución del corte de la línea.
function calculo_de_β_lh(Bbus, lines, nodes)
    """
    Entradas:   Bbus: Matriz de suscetancias del sistema
                lines: DataFrame con los datos de las líneas
                nodes: Dataframe con los datos de los nodos.
    Salida :    beta: Matriz con los factores de distribución del corte de la línea.
    """
    # Calculamos la matriz w la cual corresponde a la inversa de la matriz Bbus
    W_ini = try 
        W_ini = inv(Bbus)

    catch
        W_ini = pinv(Bbus)
    end
    # Para añadir ambas
    m, n = size(W_ini)
    W = zeros(m + 1, n + 1)
    # Hallando el nodo slack
    s = only(nodes[nodes.TYPE .== 3, "NUMBER"])

    # Añadiendo las filas y columnas del nodo slack    
    W[1:s-1, 1:s-1] = W_ini[1:s-1, 1:s-1]  # Parte superior izquierda
    W[1:s-1, s+1:end] = W_ini[1:s-1, s:end]  # Parte superior derecha
    W[s+1:end, 1:s-1] = W_ini[s:end, 1:s-1]  # Parte inferior izquierda
    W[s+1:end, s+1:end] = W_ini[s:end, s:end]  # Parte inferior derecha

    # Factores de distribución del corte de la línea.
    num_lines = nrow(lines)
    beta= zeros(num_lines,num_lines)
    for l = 1:num_lines
        k = lines.FROM[l]
        m = lines.TO[l]
        for h = 1:num_lines
            i = lines.FROM[h]
            j = lines.TO[h]
            if l != h
                beta[l,h] = (lines.X[h]/lines.X[l])*(W[i,k]-W[j,k]-W[i,m]+W[j,m])/(lines.X[h]-W[i,i]-W[j,j]+2*W[i,j])
            end
        end
    end
    return beta
end

# Función principal
lines = DataFrame(CSV.File("lines.csv"))
nodes = DataFrame(CSV.File("nodes.csv"))
Bbus = calcular_bbus(lines, nodes)
alpha = calculo_de_α_li(Bbus,lines,nodes)

# delta = calculo_de_δ_il(Bbus,lines,nodes)
beta = calculo_de_β_lh(Bbus,lines,nodes)
display(Bbus)
display(alpha)
display(beta)