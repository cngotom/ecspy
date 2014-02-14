at_exit {
    puts "AT_EXIT"
}

at_exit {
    puts "AT_EXIT2"
}

trap("KILL"){
    puts "KILLED"
}

trap("KILL"){
    puts "KILLED"
}

sleep 20