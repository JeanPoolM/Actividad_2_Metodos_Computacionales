# TAREA NO.2 : ANALISIS DE SENSIBILIDAD LINEAL
*Cálculo de los factores de sensibilidad.*

En este proyecto desarrollamos el código para el cálculo de los *factores de sensibilidad* los cuales son útililes para el analisis de contingencias en un sistema electrico de potencia, para esto se implementó la siguiente estructura:
<br>
1. **Cálculo de la matriz W.**
    Las expresiones utilizadas para el cálculo de los *factores de sensibilidad* consideran la matriz W, la cual corresponde a la inversa de la matriz $B_{bus}$ suprimiendo en esta el nodo *Slack*; dependiendo de la topología de la red es posible que la operación inversa no sea posible, debido a que la matriz en cuestión puede ser singular, esto no quiere decir que la matriz no tenga una inversa como tal, si no más bien que pueden existir infitas o multiples matrices inversas; para obtener una de estas posibles matrices que satisfagan la inversa de la matriz $B_{bus}$ se debe implementar la *pseudoinversa*.
    <br>
2. **Cálculo de la matriz de factores de sensibilidad por cambios en la generación.**

    Para calcular la matriz de factores de sensibilidad por cambios en la generación o *Generation shift factors* se creó la función "*calculo_de_α_li()*" la cual se programó teniendo como base la siguiente expresión:

    $$\alpha_{l,i} = \frac{1}{X_l}*(W_{ki}-W_{mi}) $$
    
    Por lo tanto se comenzó definiendo la cantidad de líneas (L) y nodos (N) que conforma el sistema de potencia en cuestión, teniendo en cuenta que la matriz de *Generation shift factors* tiene dimensiones de LxN se recurrio a iteraciones por medio de ciclos for anidados para calcular cada posición de esta matriz.
    <br>
3. **Cálculo de la matriz de factores de sensibilidad de distribución de corte de línea.**
    Para calcular la matriz de factores de sensibilidad de distribución de corte de línea o *Line Outage Distribution Factors* se creó la función "*calculo_de_β_lh()*" la cual se programó teniendo como base la siguiente expresión:

    $$\beta_{lk} = \frac{X_k}{X_l}*\frac{W_{in}-W_{im}-W_{jn}+W_{jm}}{X_k-(W_{ii}+W_{jj}-2*W_{ij})}$$

    Luego se definió al igual que con el cálculo de los *Generation shift factors*, la cantidad de lineas (L) y nodos (N) que componen el sistema de potencia en cuestión; teniendo en cuensta que la matriz *Line Outage Distribution Factors* debe tener dimensiones LxL se realizó el calculo de cada posición mediante iteraciones teniendo como base la expresión anterior.

**Marco teórico: Linear Sensitivity Factors**

El análisis de contingencias en sistemas eléctricos de potencia requiere herramientas que permitan evaluar rápidamente el impacto de fallas en líneas de transmisión o generación. Uno de los métodos más utilizados para este propósito es el uso de *factores de sensibilidad lineal*, que permiten aproximar cambios en los flujos de potencia en la red sin necesidad de resolver flujos de carga completos.

Los factores de sensibilidad lineal se derivan del modelo de *flujo de carga DC* y ofrecen una estimación rápida de cómo una variación en generación o una apertura de línea afecta a los flujos de potencia. Existen dos tipos principales de factores de sensibilidad:

- Factores por cambios en la generación (Generation Shift Factors)
- Factores de Distribución de corte de Línea (Line Outage Distribution Factors)

1. **Factores por cambios en la generación**
Los *factores por cambios en la generación* $alpha_{l,i}$ indican el cambio en el flujo de potencia en una línea específica $l$ cuando se produce un cambio en la generación en un nodo $i$, suponiendo que la compensación de potencia se realiza en el bus de referencia.

    *Expresión matemática:*
    $$
    \Delta f_e = \alpha_{e,i} * \Delta P_i
    $$
    donde:
    - $\Delta f_e$ es el cambio en el flujo de potencia en la línea $l$,
    - $\alpha_{e,i}$ es el factor de desplazamiento de generación,
    - $\Delta P_i$ es el cambio en la generación en el bus $i$.

2. **Factores de Distribución de corte de Línea**
Los *factores de distribución de corte de línea* $\beta_{l,k}$ cuantifican el impacto en los flujos de potencia en una línea $l$ cuando otra línea $k$ se desconecta.

    *Expresión matemática:*
    $$
    \Delta f_l = \beta_{l,k}*\Delta f_k
    $$
    donde:
    - $\Delta f_L$ es el cambio en el flujo de la línea $l$ tras la apertura de la línea $k$,
    - $\beta_{L,k}$ es el factor de distribución de salida de línea,
    - $\Delta f_k$ es el cambio en el flujo en la línea $k$ tras su apertura.

    Estos factores permiten estimar si una línea sufrirá una sobrecarga tras la pérdida de otra, lo que ayuda a tomar medidas preventivas en la operación del sistema.

Aplicación de Factores de Sensibilidad Lineal
1. **Evaluación rápida de contingencias**: Permiten analizar miles de escenarios de falla en segundos, sin necesidad de resolver flujos de carga completos.
2. **Selección de contingencias críticas**: Ayudan a identificar eventos de mayor impacto que requieren análisis detallado con modelos AC.
3. **Corrección de despacho**: Pueden usarse en herramientas de flujo de potencia óptimo con restricciones de seguridad (SCOPF) para ajustar la generación y evitar sobrecargas en caso de fallas.

**Funciones**

* **Librerias necesarias**
    - using LinearAlgebra
    - using DataFrames
    - using CSV

* **calcular_bbus()**
*Requiere*
    - Entradas:   
        - lines: DataFrame con la información de los parámetros de las líneas
        - nodes : DataFrame con la información de las magnitudes en los nodos.
    - Salidas :    
        - Bbus : Matriz que se compone de la susceptancia de cada línea del sistema y sus conexiones con los nodos.

* **calculo_de_α_li()**
*Requiere*
    - Entradas:   
        - Bbus: Matriz de suscetancias del sistema
        - lines: DataFrame con los datos de las líneas
        - nodes: Dataframe con los datos de los nodos.
    - Salida :    
        - alpha: Matriz con los factores de sensibilidad por cambio en la generación.
    
* **calculo_de_β_lh()**
*Requiere*
    - Entradas:   
        - Bbus: Matriz de suscetancias del sistema
        - lines: DataFrame con los datos de las líneas
        - nodes: Dataframe con los datos de los nodos.
    - Salida :    
        - beta: Matriz con los factores de distribución del corte de la línea.
    
**Licencia**

Programa realizado por: Jean Pool Marín
jeanpool.marin@utp.edu.co
