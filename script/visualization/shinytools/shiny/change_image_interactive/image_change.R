download.file("http://dehayf5mhw1h7.cloudfront.net/wp-content/uploads/sites/38/2016/01/18220900/Getty_011816_Bluepenguin.jpg",
              destfile = "Bowie.png")
download.file("http://3.bp.blogspot.com/_cBH6cWZr1IU/TUURNp7LADI/AAAAAAAABsY/76UhGhmxjzY/s640/penguin+cookies_0018.jpg",
              destfile = "Cookie.png")

shinyApp(
  ui = basicPage(
    selectInput("var", 
                label = "Choose a penguin to display",
                choices = c("Bowie", "Cookie"),
                selected = "Bowie"),
    imageOutput("img1")
  ),

  server = function(input, output) {
    output$img1 <- renderImage({   #This is where the image is set 
      if(input$var == "Bowie"){            
        list(src = "images/Bowie.png", height = 240, width = 300)
      }                                        
      else if(input$var == "Cookie"){
        list(src = "images/joan.jpeg", height = 240, width = 300)
      }
    }, deleteFile = F)})

