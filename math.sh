#!/bin/bash

# Functions to perform mathematical operations more easily in Shell Script.
# -------------------------------------------------------------------------
# Date: August 15, 2022
# Author: Fernando Vicente
# License: GPL
# Version: 0.1

# Most important irrational numbers
PI=3.141592653
TAU=6.28318530
PHI=1.61803398
E=2.718281828

function isnumeric(){
    # Checks if the received parameter is numeric.
    #
    # Parameters:
    # -----------
    #   Any parameter
    # Returns:
    # --------
    #   0 if the parameter is not numeric
    #   1 if the parameter is numeric
    #   2 if the parameter is numeric in Spanish format

    #   1.1 .1 1,1

    if [[ $1 =~ ^(-?[0-9]+)?(\.[0-9]+)?$ ]]
    then
        echo 1
    elif [[ $1 =~ ^(-?[0-9]+)?(\,[0-9]+)?$ ]]
    then
        echo 2
    else
        echo 0
    fi
}

function isinteger(){
    # Returns 1 if the received parameter is an integer. 0 otherwise.
    #
    # Parameters:
    # -----------
    #   Any value.
    # Returns:
    # --------
    #   1 - parameter is integer.
    #   0 - otherwise.
    
    if [[ $1 =~ ^-?[0-9]+$ ]]
    then
        echo 1
    else
        echo 0
    fi
}

function abs(){
    # Returns the absolute value of the received number.
    #
    # Parameters:
    # -----------
    #   Any number.
    # Returns:
    #   Absolute value of number.
    if [ $(isnumeric) -gt 0 ]
    then 
        if [ ${1:0:1} = "-" ]
        then 
            echo ${1:1}
        else
            echo $1
        fi
    else
        echo ""
    fi
}

function onlynumbers(){
    # Returns only the numbers received as a parameter.
    #
    # Parameters:
    # -----------
    #   Parameters collection.
    # Returns:
    #   A text string with the received numbers in operable format.

    number=""
    for i in $@
    do
        if [ $(isnumeric $i) -eq 1 ]
        then
            number=$number" "$i
        elif [ $(isnumeric $i) -eq 2 ]
        then
            i=$(echo $i | tr , .)
            number=$number" "$i
        fi
    done
    number=${number:1}
    echo $number
}

function maximumdecimals(){
    # Returns the number of decimal places of the number with the largest number 
    #   of decimal places received as a parameter.
    # Parameters:
    # -----------
    #   Any parameter.
    # Returns:
    # --------
    #   Greater number of decimals received.

    higher=0
    numbers=$(onlynumbers $@)
    for i in $numbers
    do 
        posdot=$(expr index $i ".")
        if [ $posdot -gt 0 ]
        then
            decimal=${i##*.}
            if [ ${#decimal} -gt $higher ]
            then
                higher=${#decimal}
            fi
        fi
    done
    echo $higher
}

function add(){
    # Returns the sum of all received numbers.
    #
    # Parameters:
    # -----------
    #   Collections of numbers.
    # Returns:
    # --------
    #   Sum of the numbers.

    addends=""
    for i in $@
    do
        if [ $(isnumeric $i) -eq 1 ]
        then
            addends=$addends"+"$i
        elif [ $(isnumeric $i) -eq 2 ]
        then
            i=$(echo $i | tr , .)
            addends=$addends"+"$i
        fi
    done
    addends=${addends:1}
    if [ "$addends" = "" ]
    then 
        echo 0
    else
        result=$(echo "$addends" | bc)
        echo $result
    fi
}


function multiply(){
    # Returns the multiplication of all received numbers.
    #
    # Parameters:
    # -----------
    #   Collections of numbers.
    # Returns:
    # --------
    #   Multiplication of the received numbers.

    multiplier=""
    for i in $@
    do
        if [ $(isnumeric $i) -eq 1 ]
        then
            multiplier=$multiplier"*"$i
        elif [ $(isnumeric $i) -eq 2 ]
        then
            i=$(echo $i | tr , .)
            multiplier=$multiplier"*"$i
        fi
    done
    multiplier=${multiplier:1}
    if [ "$multiplier" = "" ]
    then 
        echo 0
    else
        result=$(echo "$multiplier" | bc)
        echo $result
    fi
}


function subtraction(){
    # Returns the subtraction of the first received number minus the second 
    #   received number minus the third received number...
    #
    # Parameters:
    # -----------
    #   Collections of numbers.
    # Returns:
    # --------
    #   Subtraction of the received numbers.
    
    numbers=$(onlynumbers $@)
    if [ "$numbers" = "" ]
    then 
        echo 0
    else
        numbers=$(echo "$numbers" | tr " " -)
        result=$(echo "$numbers" | bc)
        echo $result
    fi
}


function division(){
    # Returns the division of two numbers.
    #
    #   If it receives a third parameter, it will indicate the number 
    #       of decimal places.
    #   If not, the result will have as many decimal places as the number 
    #       with the greatest number of decimal places.
    #
    # Parameters:
    # -----------
    #   2 or 3 numbers.
    # Returns:
    # --------
    #   The division of the received numbers.

    if [ $(isnumeric $1) -gt 0 -a $(isnumeric $2) -gt 0 ]
    then 
        if [ $3 ]
        then
            if [ $(isnumeric $3) -gt 0 -a $(isinteger $3) -gt 0 ]
            then
                decimals=$3
            fi
        fi
        if [ ! $decimals ]
        then
            decimals=$(maximumdecimals $1 $2)
        fi
        decimals=$(abs $decimals)
        result=$(echo "scale=$decimals;$1/$2" | bc)
        if [ ${result:0:1} = "." ]
        then
            result="0"$result
        fi
        if [ ${result:0:2} = "-." ]
        then
            result="-0"${result:1}
        fi
        
        echo $result

    else
        echo ""
    fi

}

function pow(){
    # Returns the power of the first number raised to the second.
    #
    # Parameters:
    # -----------
    #   2 or numbers.
    # Returns:
    # --------
    #   The power of the first number raised to the second.
    #   Empty string if not received two numbers.
    
    if [ $1 ] && [ $2 ]
    then
        if [ $(isnumeric $1) -gt 0 -a $(isnumeric $2) -gt 0 ]
        then 
            base=$(onlynumbers $1)
            exponent=$(onlynumbers $2)
            if [ $(isinteger $base) -gt 0 -a $(isinteger $exponent) -gt 0 ]
            then
                if [ ${exponent:0:1} = "-" ]
                then
                    result=$(echo "scale=6;$base^$exponent" | bc)
                    if [ ${result:0:1} = "." ]
                    then
                        echo "0"$result
                    else
                        echo $result
                    fi
                    
                else
                    echo $(echo $base^$exponent | bc)
                fi
            elif [ $(isinteger $exponent) -eq 0 ]
            then
                echo $(echo "scale=6;$base^$exponent" | bc 2> /dev/null)
            else
                echo $(echo "scale=6;$base^$exponent" | bc)
            fi
        else
            echo ""
        fi
    else
        echo ""
    fi
}

function sqrt(){
    # Return the square root of a number
    #
    # Parameters:
    # -----------
    #   A number.
    # Returns:
    # --------
    #   The square root of first number.
    #   Empty string if not received a positive number.

    if [ $1 ] && [ $(isnumeric $1) -gt 0 ]
    then
        number=$(onlynumbers $1)
        if [ ${number:0:1} = "-" ]
        then
            echo ""
        else
            echo $(echo "sqrt($number)" | bc -l)
        fi
    else
        echo ""
    fi
}


function max(){
    # Returns the higher of the numbers received as a parameter.
    #
    # Parameters:
    # -----------
    #   Any parameter.
    # Returns:
    # --------
    #   The higher number.
    #   0 if there are no numbers.

    numbers=$(onlynumbers $@)
    higher=0
    for i in $numbers
    do
        if [ $(echo "$i>$higher" | bc) -eq 1 ]
        then
            higher=$i
        elif [ $(echo "$i<$higher" | bc) -eq 1 ] && [ $higher -eq 0 ]
        then
            higher=$i
        fi
    done
    echo $higher
}

function min(){
    # Returns the lower of the numbers received as a parameter.
    #
    # Parameters:
    # -----------
    #   Any parameter.
    # Returns:
    # --------
    #   The lower number.
    #   0 if there are no numbers.

    numbers=$(onlynumbers $@)
    lower=0
    for i in $numbers
    do
        if [ $(echo "$i<$lower" | bc) -eq 1 ]
        then
            lower=$i
        elif [ $(echo "$i>$lower" | bc) -eq 1 ] && [ "$lower" = "0" ]
        then
            lower=$i
        fi
    done
    echo $lower

}

function randint(){
    # Return a random integer N such that a <= N <= b. 
    #
    # Parameters:
    # -----------
    #   1 or 2 numbers.
    #       1 number: upper limit. Range: 0-$1
    #       2 numbers: lower limit. Range: $1-$2
    # Returns:
    # --------
    #   A random number.
    #   0 if there are no numbers.

    if [ $1 ] && [ $(isinteger $1) -gt 0 ]
    then
        if [ $2 ] && [ $(isinteger $2) -gt 0 ]
        then
            echo $(eval echo {$1..$2} | tr " " "\n" | shuf -n 1)
        else
            echo $(eval echo {0..$1} | tr " " "\n" | shuf -n 1)
        fi
    else
        echo ""
    fi

}
