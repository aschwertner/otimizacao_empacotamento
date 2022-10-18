# ------------------------------------------------------------------------------
# Pacotes
# ------------------------------------------------------------------------------


using Plots


# ------------------------------------------------------------------------------
# Funções básicas
# ------------------------------------------------------------------------------


"""

    caixa(L, W)

Cria a forma de um envelope retangular de dimensões L x W.

    - 'L': comprimento do envelope retangular.
    - 'W': largura do envelope retangular.

Retorna um objeto do tipo Shape.

"""
caixa(L, W) = Shape([0, W, W, 0], [0, 0, L, L])
#caixa(L, W) = Shape([0, L, L, 0], [0, 0, W, W])

"""

    poligono(x_ref, y_ref, lista_poligono)

Cria a forma de um polígono referenciado a partir do ponto (x_ref, y_ref).

    - 'x_ref': abscissa do ponto de referência.
    - 'y_ref': ordenada do ponto de referência.
    - 'lista_poligono': lista de vértices do polígono.

Retorna um objeto do tipo Shape.

"""
poligono(x_ref, y_ref, lista_poligono) = Shape(x_ref .+ lista_poligono[1:2:end], y_ref .+ lista_poligono[2:2:end])


"""

    poligono_rotacionado(x_ref, y_ref, θ, lista_poligono)

Cria a forma de um polígono referenciado a partir do ponto (x_ref, y_ref) e rotacionado com ângulo θ.

    - 'x_ref': abscissa do ponto de referência.
    - 'y_ref': ordenada do ponto de referência.
    - 'θ': ângulo de rotação.
    - 'lista_poligono': lista de vértices do polígono.

Retorna um objeto do tipo Shape.

"""
poligono_rotacionado(x_ref, y_ref, θ, lista_poligono) = Shape(
                                                                x_ref .+ cos(θ) * lista_poligono[1:2:end] .- sin(θ) * lista_poligono[2:2:end], 
                                                                y_ref .+ sin(θ) * lista_poligono[1:2:end] .+ cos(θ) * lista_poligono[2:2:end]
                                                                )


"""

    circulo(x_ref, y_ref, raio)

Cria a forma de um círculo referenciado a partir do ponto (x_ref, y_ref) e de raio 'raio'.

    - 'x_ref': abscissa do centro de referência.
    - 'y_ref': ordenada do centro de referência.
    - 'raio': raio do círculo.

Retorna um objeto do tipo Shape.

"""
function circulo(x_ref, y_ref, raio)
    θ = 0:5:360
    Shape(raio * sind.(θ) .+ x_ref, raio * cosd.(θ) .+ y_ref)
end


# ------------------------------------------------------------------------------
# Funções para desenhar problema e solução.
# ------------------------------------------------------------------------------


"""

    translacao_poligono(lista_vertices_pol)

Translada cada polígono até a origem.

    - 'lista_vertice_pol': lista contendo a lista de vértices de cada polígono.

"""
function translacao_poligono(lista_vertices_pol)

    # Faz uma cópia da lista de vértices
    nova_lista = deepcopy(lista_vertices_pol)
    
    # Calcula o número de polígonos
    np = length(nova_lista)
    
    for i = 1:np

        # Calcula o número de vértices da componente convexa j do polígono i
        nvert = Int(length(nova_lista[i]) / 2)

        # Subtrai as coordenadas do primeiro vértice da primeira componente convexa dos demais.
        for k = 1:nvert

            nova_lista[i][(2 * k - 1):(2 * k)] -= lista_vertices_pol[i][1:2]
    
        end
    
    end
    
    return nova_lista

end


"""

    plota_problema(lista_centros_circ, lista_raios_circ, lista_vertice_pol, L, W)

Plota o problema de corte e empacotamento.

    - 'lista_centros_circ': lista contendo a lista dos centros dos círculos.
    - 'lista_raios_circ': lista contendo os raios dos círculos.
    - 'lista_vertice_pol': lista contendo a lista de vértices de cada polígono.
    - 'L': comprimento do envelope retangular.
    - 'W': largura do envelope retangular.

"""
function plota_problema(lista_centros_circ, lista_raios_circ, lista_vertice_pol, L, W)

    nc = length(lista_raios_circ)
    np = length(lista_vertice_pol)

    # Plota o envelope retangular.
    fig = plot(caixa(L, W), fillcolor = :white, legend = false, aspect_ratio = :equal)

    # Plota os círculos.
    for i = 1:nc
        plot!(fig, circulo(lista_centros_circ[i][1], lista_centros_circ[i][2], lista_raios_circ[i]), fillcolor = plot_color(:red, 0.5))
    end

    # Plota os polígonos.
    for i = 1:np
        plot!(fig, poligono(0.0, 0.0, lista_vertice_pol[i]), fillcolor = plot_color(:blue, 0.5))
    end

    fig

end


"""

    plota_solucao(lista_raios_circ, lista_vertice_pol, L, W, x)

Plota a solução do problema de corte e empacotamento.

    - 'lista_raios_circ': lista contendo os raios dos círculos.
    - 'lista_vertice_pol': lista contendo a lista de vértices de cada polígono (translado para origem).
    - 'L': comprimento do envelope retangular.
    - 'W': largura do envelope retangular.
    - 'x': solução encontrada pelo solver no formato [xC, yC, xP, yP, θP].

"""
function plota_solucao(lista_raios_circ, lista_vertice_pol, L, W, x)

    nc = length(lista_raios_circ)
    np = length(lista_vertice_pol)

    # Plota o envelope retangular.
    fig = plot(caixa(L, W), fillcolor = :white, legend = false, aspect_ratio = :equal)

    # Plota os círculos.
    for i = 1:nc
        plot!(fig, circulo(x[2*i-1], x[2*i], lista_raios_circ[i]), fillcolor = plot_color(:red, 0.5))
    end

    # Plota os polígonos.
    for i = 1:np
        j = 2 * nc + 3 * i
        plot!(fig, poligono_rotacionado(x[j - 2], x[j - 1], x[j], lista_vertice_pol[i]), fillcolor = plot_color(:blue, 0.5))
    end

    fig

end


# ------------------------------------------------------------------------------
# Funções com componentes convexas.
# ------------------------------------------------------------------------------

"""

    translacao_poligono_cp(lista_vertices_pol)

Translada cada polígono até a origem.

    - 'lista_vertice_pol': lista contendo a lista de vértices de cada componente convexa de cada polígono.

"""
function translacao_poligono_cp(lista_vertices_pol)

    # Faz uma cópia da lista de vértices
    nova_lista = deepcopy(lista_vertices_pol)
    
    # Calcula o número de polígonos
    np = length(nova_lista)
    
    for i = 1:np
        
        # Calcula o número de componentes convexas do polígono i.
        ncpi = length(nova_lista[i])

        for j = 1:ncpi
            
            # Calcula o número de vértices da componente convexa j do polígono i
            nvert = Int(length(nova_lista[i][j]) / 2)

            # Subtrai as coordenadas do primeiro vértice da primeira componente convexa dos demais.
            for k = 1:nvert

                nova_lista[i][j][(2 * k - 1):(2 * k)] -= lista_vertices_pol[i][1][1:2]
        
            end
        end
    end
    
    return nova_lista

end


"""

    plota_problema_cp(lista_centros_circ, lista_raios_circ, lista_vertice_pol, L, W)

Plota o problema de corte e empacotamento.

    - 'lista_centros_circ': lista contendo a lista dos centros dos círculos.
    - 'lista_raios_circ': lista contendo os raios dos círculos.
    - 'lista_vertice_pol': lista contendo a lista de vértices de cada componente convexa de cada polígono.
    - 'L': comprimento do envelope retangular.
    - 'W': largura do envelope retangular.

"""
function plota_problema_cp(lista_centros_circ, lista_raios_circ, lista_vertice_pol, L, W)

    nc = length(lista_raios_circ)
    np = length(lista_vertice_pol)

    # Plota o envelope retangular.
    fig = plot(caixa(L, W), fillcolor = :white, legend = false, aspect_ratio = :equal)

    # Plota os círculos.
    for i = 1:nc
        plot!(fig, circulo(lista_centros_circ[i][1], lista_centros_circ[i][2], lista_raios_circ[i]), fillcolor = plot_color(:red, 0.5))
    end

    # Plota os polígonos.
    for i = 1:np
        # Calcula o número de componentes convexas do polígono i.
        ncpi = length(lista_vertice_pol[i])

        # Plota cada componente convexa.        
        for j = 1:ncpi
            plot!(fig, poligono(0.0, 0.0, lista_vertice_pol[i][j]), fillcolor = plot_color(:blue, 0.5))
        end
    end

    fig

end

"""

    plota_solucao_cp(lista_raios_circ, lista_vertice_pol, L, W, x)

Plota a solução do problema de corte e empacotamento.

    - 'lista_raios_circ': lista contendo os raios dos círculos.
    - 'lista_vertice_pol': lista contendo a lista de vértices de cada componente convexa de cada polígono (translado para origem).
    - 'L': comprimento do envelope retangular.
    - 'W': largura do envelope retangular.
    - 'x': solução encontrada pelo solver no formato [xC, yC, xP, yP, θP].

"""
function plota_solucao_cp(lista_raios_circ, lista_vertice_pol, L, W, x)

    # Cálcula o números de círculos e polígonos
    nc = length(lista_raios_circ)
    np = length(lista_vertice_pol)

    # Plota o envelope retangular.
    fig = plot(caixa(L, W), fillcolor = :white, legend = false, aspect_ratio = :equal)

    # Plota os círculos.
    for i = 1:nc
        plot!(fig, circulo(x[2*i-1], x[2*i], lista_raios_circ[i]), fillcolor = plot_color(:red, 0.5))
    end

    # Plota os polígonos.
    for i = 1:np
        # Deslocamento no vetor de soluções 'x'.
        k = 2 * nc + 3 * i

        # Calcula o número de componentes convexas do polígono i.
        ncpi = length(lista_vertice_pol[i])

        # Plota cada componente convexa.
        for j = 1:ncpi
            plot!(fig, poligono_rotacionado(x[k - 2], x[k - 1], x[k], lista_vertice_pol[i][j]), fillcolor = plot_color(:blue, 0.5))
        end
    end

    fig

end