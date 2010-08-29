xml.instruct!(:xml, :encoding => "UTF-8")
xml.OpenSearchDescription(:xmlns => "http://a9.com/-/spec/opensearch/1.1/") do  |opens|
	opens.ShortName("Search ArXiv.org")
	opens.Description("Search scientific papers at arXiv.org")
	opens.Url(:type => 'application/atom+xml', :template => "http://#{request.host}/search/?q={searchTerms}")
end
