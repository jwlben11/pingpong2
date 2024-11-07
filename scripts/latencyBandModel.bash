#! /bin/bash
# Expect protocol name as first parameter (tcp or udp)

# Define input and output file names
ThroughFile="../data/$1_throughput.dat";
PngName="../data/LB$1.png";

#getting the first and the last line of the file
HeadLine=($(head $ThroughFile --lines=1))
TailLine=($(tail $ThroughFile --lines=1))

#getting the information from the first and the last line
FirstN=${HeadLine[0]}
LastN=${TailLine[0]}

# TO BE DONE START
if [[ ! -f $ThroughFile || ! -s $ThroughFile ]]; then
    echo "Error: File $ThroughFile does not exist or is empty."
    exit 1
fi
# TO BE DONE START
# Calcolo della latenza e della banda
# Supponiamo che il file di throughput contenga due colonne: 
# la prima colonna è la dimensione del messaggio e la seconda è il throughput

# Estrai i dati dal file
data=($(cat $ThroughFile))

# Inizializza variabili
total_size=0
total_throughput=0
count=0

# Itera attraverso i dati per calcolare la latenza e la banda
for ((i=0; i<${#data[@]}; i+=2)); do
    msg_size=${data[i]}
    throughput=${data[i+1]}
    
    total_size=$((total_size + msg_size))
    total_throughput=$(echo "$total_throughput + $throughput" | bc)
    count=$((count + 1))
done

# Calcola la banda media
Band=$(echo "$total_throughput / $count" | bc -l)

# Calcola la latenza media (assumendo throughput in KB/s e msg_size in B)
Latency=$(echo "scale=10; $total_size / ($total_throughput * 1024)" | bc -l)
# TO BE DONE END

# Plotting the results
gnuplot <<-eNDgNUPLOTcOMMAND
  set term png size 900, 700
  set output "${PngName}"
  set logscale x 2
  set logscale y 10
  set xlabel "msg size (B)"
  set ylabel "throughput (KB/s)"
  set xrange[$FirstN:$LastN]
  lbmodel(x)= x / ($Latency + (x/$Band))

# TO BE DONE START
   plot "$ThroughFile" using 1:2 with lines title "Throughput", \
       lbmodel(x) with lines title "LB Model"
# TO BE DONE END

  clear

eNDgNUPLOTcOMMAND
