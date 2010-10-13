class FSEvent
  attr_reader :paths, :latency, :callback, :pipe
  
  def watch(paths, options = {}, &callback)
    @paths    = paths.is_a?(Array) ? paths : Array.new(paths.split)
    @latency  = options[:latency] || 0.5
    @callback = callback
  end
  
  def run
    launch_bin
    listen
  end
  
  def stop
    Process.kill("KILL", pipe.pid) if pipe
  end
  
private
  
  def bin_path
    File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'bin'))
  end
  
  def launch_bin
    @pipe = IO.popen("#{bin_path}/rb-fsevent #{paths.join(',')} #{latency}")
  end
  
  def listen
    while !pipe.eof?
      if line = pipe.readline
        modified_dir_paths = line.split(" ")
        callback.call(modified_dir_paths)
      end
    end
  rescue Interrupt
    stop
  end
  
end