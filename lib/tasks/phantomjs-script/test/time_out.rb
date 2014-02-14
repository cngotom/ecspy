require 'timeout'

def my_system(cmd,timeout = 60)
	pid = fork do
		exec(*cmd)
		exit! 127
	end

	yield pid if block_given?

	begin
		Timeout.timeout(timeout) do
			Process.waitpid(pid)
		end
		#puts $?
	rescue Timeout::Error
		puts "#{cmd} time out "
		Process.kill 9, pid
	end
end

require 'timeout'
def exec_with_timeout(cmd,timeout = 60)
	pipe = IO.popen(cmd)
	begin
		Timeout.timeout(timeout) do
			pipe.read
		end
	rescue Timeout::Error
		puts "#{cmd} time out "
		Process.kill 9, pipe.pid
		'killed because timeout'
	end
end


#my_system("echo 123",5) {|pid| puts pid}


puts exec_with_timeout('sleep 10')


puts 'end'





# pid = Process.fork  
# puts "current pid :#{pid}"  
# if pid.nil? then  
#   puts "# In child"  
#   #puts exec('ls ~')  
#   sleep 10
#   puts 'child exit'
# else  
#   puts "# In Parent"  
#   puts "Sub Process ID:#{Process.wait(pid)}"  

# end  
# require 'timeout'


# pid = fork{
# 	`ruby`
# }
# begin
#     Timeout.timeout(5) do
#     	puts pid
#     	puts '__'
#     	puts $?
#         Process.wait
#     end
# rescue Timeout::Error
# 	puts 'timeout'
#    # Process.kill 9, pid
#     # collect status so it doesn't stick around as zombie process
#    # Process.wait pid
# end