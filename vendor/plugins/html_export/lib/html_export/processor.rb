module HTMLExport
  class Processor
    def self.generate(params={})
      category_name = params.fetch(:category_name, Configuration.category)
      reporting_cat = Category.find_by_name(category_name)
      reporting_notes_num = Note.count(:all, :conditions => {:category_id => reporting_cat})
      title = "Dradis Framework - v#{Core::VERSION::STRING}"
      notes = Note.find( :all, :conditions => {:category_id => reporting_cat} )

      erb = ERB.new( File.read(Configuration.template) )

      erb.result( binding ) 
    end
  end
end
