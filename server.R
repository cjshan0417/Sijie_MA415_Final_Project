
# MA415 Final Project: Visualizing Twitter Using Shiny
# Date: Dec. 12, 2017
# Author: CJ/Sijie Shan

# prepare packages
# if (!require("pacman")) install.packages("pacman")
# pacman::p_load("twitteR", "reshape", "ROAuth", "tm", 
#                "wordcloud", "shiny", "tidyverse", "tidytext")

require("twitteR")
require("reshape")
require("ROAuth")
require("tm")
require("wordcloud")
require("shiny")
require("tidyverse")
require("tidytext")

# set up connection
api_key             <- "gXqBTqK0l8m27VzecET7DhBAK"
api_secret          <- "yIu5bA1dJlKiIIEk6VpEVUeXJGBzrpNg2HzA1h78lmjumneMRX"
access_token        <- "927637296295415809-6jHILffeAgkE4UrnRhQRMzXIHOX1MO1"
access_token_secret <- "ZaoYIuFITfZiUlio5UgOHQqJgPeMEZedgzex3vfMsaAcX"
setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)

shinyServer(function(input, output) {
  
  word_freq <- eventReactive(input$refresh,
  {
    user_id <- "@katyperry"  # default value for @username
    if(input$new_user_id != "") {
      user_id <- input$new_user_id  # assign new id if exists
    }
    
    # main panel title
    output$user_id <- renderText({paste("Word Cloud for", user_id)})
    
    # fetch data
    tweets_raw <- userTimeline(user_id, n = 3200)
    
    # remove retweets
    tweets_df <- twListToDF(strip_retweets(tweets_raw, strip_manual = TRUE, strip_mt = TRUE))
    
    # normalize data
    tweets_df$text <- iconv(tweets_df$text, 'latin1', 'ASCII', 'byte')
    
    # build a corpus, and specify the source to be character vectors
    myCorpus <- Corpus(VectorSource(tweets_df$text))
    
    # remove extra whitespace
    myCorpus <- tm_map(myCorpus, stripWhitespace)
    
    # convert to lower case
    myCorpus <- tm_map(myCorpus, content_transformer(tolower))
    
    # remove tabs
    rm_tab   <- function(x) gsub("[ |\t]{2,}", "", x)
    myCorpus <- tm_map(myCorpus, content_transformer(rm_tab))
    
    # remove emoji
    rm_emoj  <- function(x) gsub("<.*?>", "", x)
    myCorpus <- tm_map(myCorpus, content_transformer(rm_emoj))
    
    # remove stopwords
    data(stop_words)
    extra_words <- c("amp", 1:9, "[a-z]")  # add extra stopwords here
    myStopwords <- c(unique(unlist(stop_words$word)), extra_words)
    myCorpus    <- tm_map(myCorpus, removeWords, myStopwords)
    
    # remove urls
    rm_url   <- function(x) gsub("http[^[:space:]]*", "", x)
    myCorpus <- tm_map(myCorpus, content_transformer(rm_url))
    
    # replace @username
    rm_username <- function(x) gsub("@\\w+", "", x)
    myCorpus    <- tm_map(myCorpus, content_transformer(rm_username))
    
    # remove punctuation
    rm_punc  <- function(x) gsub("[[:punct:]]", "", x)
    myCorpus <- tm_map(myCorpus, content_transformer(rm_punc))
    
    # build term document matrix
    tdm <- TermDocumentMatrix(myCorpus, control = list(wordLengths = c(1, Inf)))
    m  <- as.matrix(tdm)
    
    # calculate the frequency of words and sort it by frequency
    word_freq <- sort(rowSums(m), decreasing = T)
  
}, ignoreNULL = FALSE)

  output$word_cloud = renderPlot({
    
    # draw word cloud with specified number of minimum frequency
    wordcloud(words = names(word_freq()), 
              freq  = word_freq(),
              scale = c(4, 1),
              max.words = 50,
              min.freq = input$min_freq, 
              colors = brewer.pal(8, "Dark2"), 
              random.color = TRUE,
              random.order = F)
    })
})
