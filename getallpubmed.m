function summary_table = getallpubmed(apikey,searchterm)

% The function getallpubmed takes in two compulsory inputs:
% an individiual API key (obtained from NCBI website) and
% terms to be searched in Pubmed, and it ouputs
% the table containing the Pubmed IDs, publication years,
% titles, authors, journals, and DOIs of the publications
% matching the search terms

% Error checking for required number of inputs
if nargin < 2
    error('Not enough input arguments.');
end

if nargin > 2
   error('Too many input arguments.');
end

% Create base URL for Entrez database
baseURL = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';

% Set E-utility to ESearch and database to Pubmed
eutil = 'esearch.fcgi?';
dbParam = 'db=pubmed';

% Set api key parameter to apikey
apikeyParam = ['&api_key=',apikey];

% Set term parameter to SEARCHTERM
termParam = ['&term=',searchterm];

% Save the search results to the user history
usehistoryParam = '&usehistory=y';

% Create search URL
esearchURL = [baseURL, eutil, dbParam, apikeyParam, termParam,...
    usehistoryParam];

searchReport = webread(esearchURL);

% Extract query key and web environment identifiers for the search to
% access the search results using EFEtch
ncbi = regexp(searchReport,...
    '<QueryKey>(?<QueryKey>\w+)</QueryKey>\s*<WebEnv>(?<WebEnv>\S+)</WebEnv>',...
    'names');

% Get a document summary of the search results using EFetch
docsummary=webread([baseURL 'efetch.fcgi?db=pubmed&rettype=docsum&retmode=xml&WebEnv=',...
    ncbi.WebEnv,'&query_key=',ncbi.QueryKey]);

% Extract the Pubmed IDs
Pubmed_ID = regexp(docsummary,'(?<=<Id>)\w*(?=</Id>)','match');

% Extract the publication years
PublicationDate = regexp(docsummary,'(?<=<Item Name="PubDate" Type="Date">).*?(?=</Item>)',...
    'match');
for n = 1:length(PublicationDate)
    Publication_Year{n} = PublicationDate{n}(1:4);
end

% Extract article titles
titlehtml = regexp(docsummary,'(?<=<Item Name="Title" Type="String">).*?(?=</Item>)',...
    'match');
for ii = 1:length(titlehtml)
    Title{ii} = extractHTMLText(extractHTMLText(titlehtml{ii}));
end

% Extract the authors' list
authorshtml = regexp(docsummary,'(?<=<Item Name="AuthorList" Type="List">).*?(?=<Item Name="LastAuthor" Type="String">)',...
    'match');
% Splits the authors surnames from initials, add a comma after the
% initials, and puts the list back together (does not work if the surname is
% made up of two separate part though)
for i = 1:length(authorshtml)
    authorslist1{i} = extractHTMLText(authorshtml{i});
    Authors{i} = string(split(authorslist1{i}));
    Authors{i}(2:2:end-1) = Authors{i}(2:2:end-1)+',';
    Authors{i} = join(Authors{i});
end

% Extract the journal names
Journal = regexp(docsummary,'(?<=<Item Name="Source" Type="String">).*?(?=</Item>)',...
    'match');

% Extract the DOIs
DOI = regexp(docsummary,'(?<=<Item Name="DOI" Type="String">).*?(?=</Item>)',...
   'match'); 

% Combine all the information into a summary table output
summary_table = table(Pubmed_ID', Publication_Year', Title', Authors', Journal', DOI',...
    'VariableNames',{'Pubmed_ID', 'Publication_Year', 'Title', 'Authors', 'Journal','DOI'});

