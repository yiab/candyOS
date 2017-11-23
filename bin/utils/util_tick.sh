#!/bin/sh

declare __l_a_s_t__s_t_a_r_t__t_i_m_e;
function tick()
{
    if [ -n "${__l_a_s_t__s_t_a_r_t__t_i_m_e}" ]; then
        local end_tm=`date +%s%N`;
        local use_tm=`echo $end_tm ${__l_a_s_t__s_t_a_r_t__t_i_m_e} | awk '{ print ($1 - $2) / 1000000000}'`
        echo "$1任务结束，用时$use_tm秒"
    fi;
    tick_start
}

function tick_start()
{
    __l_a_s_t__s_t_a_r_t__t_i_m_e=`date +%s%N`;
}
