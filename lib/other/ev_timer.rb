def time(ev, transs, sample)
  GC::Profiler.clear
  start = Time.now
  transs.each{|tr| ev.evaluate(tr, sample: sample) }
  time_value = Time.now - start
  gc_value = GC::Profiler.total_time
  {time:time_value, gc:gc_value}
end

def time_everything
  GC::Profiler.enable
  total = Time.now
  transs = Transaction.all
  ExplanatoryVariable.lookup(:addr_ia).evaluate(transs.first)
  sample = TrainingSample.new('lib/data/big_sample.csv')
  times = ExplanatoryVariable.catalog.reduce({}) do |hmemo, (key, value)|
    hmemo[key] = time(value, transs, sample)
    hmemo
  end
  p "time_everything took #{Time.now - total} seconds"
  times.sort_by{|key, value| value[:time]}
end