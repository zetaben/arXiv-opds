class ArXiv
def initialize
	@@cats=YAML.load(open('cats_bis.yml'))
end

def top
	@@cats['root'].to_a.sort_by(&:first)
end

def subcat?(cat)
	!@@cats[cat].nil?
end

def subcats(cat)
	ret=[]
	ret.push(['All' , cat]) if subcat?(cat)
	ret+=@@cats[cat].to_a.sort_by(&:first)
	ret
end

def url(cat)
		"http://export.arxiv.org/rss/#{cat}"
end

end
