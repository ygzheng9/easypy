# Install
install.packages("tm")  # for text mining
install.packages("SnowballC") # for text stemming
install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes
install.packages("SnowballC")

# Load
library("NLP")
library("tm")
library("SnowballC")
library("RColorBrewer")
library("wordcloud")

setwd("~/Documents/playground/easypy/notebooks/julia/self/r")

# Read the text file from internet
# filePath <- "http://www.sthda.com/sthda/RDoc/example-files/martin-luther-king-i-have-a-dream-speech.txt"
filePath <- "../dataset/i-have-a-dream-speech.txt"
text <- readLines(filePath)


# Load the data as a corpus
docs <- Corpus(VectorSource(text))

inspect(docs)

# Text Transformation
# Transformation is performed using tm_map() function to replace, for example, special characters from the text.
# Replacing “/”, “@” and “|” with space:
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")

# Convert the text to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# Text stemming
docs <- tm_map(docs, stemDocument)


# Step 4 : Build a term-document matrix
dtm <- TermDocumentMatrix(docs)

# term by row, document by column
m <- as.matrix(dtm)

# 一行的所有列加总
v <- sort(rowSums(m), decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)

head(d, 10)

# Step 5 : Generate the Word cloud
set.seed(1234)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))


# Explore frequent terms and their associations
findFreqTerms(dtm, lowfreq = 4)

findAssocs(dtm, terms = "freedom", corlimit = 0.3)

head(d, 10)

barplot(d[1:10,]$freq, las = 2, names.arg = d[1:10,]$word,
        col ="lightblue", main ="Most frequent words",
        ylab = "Word frequencies")
