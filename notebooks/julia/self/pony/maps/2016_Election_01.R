library("ggplot2")
library("RColorBrewer")
library("ggthemes")
library("ggmapr")
library("shiny")
library("shinydashboard")

options(stringsAsFactors=FALSE,check.names=FALSE)

# 这里有问题：数据文件？
newdata <- read.csv("./USA_mapin/President.csv") 

# 这里有问题：states 哪里来的
ggplot(states,aes(long,lat,group=group))+
  geom_polygon(fill=NA,col="grey")+
  coord_map("polyconic")+
  theme_map()

states<-states %>% 
  filter(NAME!="Puerto Rico") %>% 
  shift(NAME=="Hawaii",shift_by=c(52.5,5.5))%>%
  scale(NAME=="Alaska",scale=0.25,set_to=c(-117,27))%>% 
  filter(lat>20)

states$NAME<-as.character(states$NAME)

# 这里我用了最新发现的可以处理多边形局部经纬度的包，大大简化了对美国海外两州（阿拉斯加和夏威夷）的经纬度移动。
ggplot(states,aes(long,lat,group=group))+
  geom_polygon(fill=NA,col="grey")+
  coord_map("polyconic")+
  theme_map()


# 合并地图数据和选举结果数据：
American_data <- states %>% merge(newdata, by.x="NAME",by.y="STATE_NAME")

# 获取各州物理位置中心：
midpos <- function(AD1){mean(range(AD1,na.rm=TRUE))} 
centres<- ddply(American_data,.(STATE_ABBR),colwise(midpos,.(long,lat)))
mynewdata<-join(centres,newdata,type="full")


# 美国总统大选各州选举人票数分布：
ggplot()+
  geom_polygon(data=American_data,aes(x=long,y=lat,group=group),colour="grey",fill="white")+
  geom_point(data=mynewdata,aes(x=long,y=lat,size=Count,fill=Count),shape=21,colour="black")+
  scale_size_area(max_size=15)+ 
  scale_fill_gradient(low="white",high="#D73434")+
  coord_map("polyconic") +
  theme_map() %+replace% theme(legend.position ="none")

# 美国总统大选投票结果双方获胜州分布情况:
ggplot(American_data,aes(x=long,y=lat,group=group,fill=Results))+
  geom_polygon(colour="white")+
  scale_fill_manual(values=c("#19609F","#CB1C2A"),labels=c("Hillary", "Trump"))+
  coord_map("polyconic") +
  guides(fill=guide_legend(title=NULL))+ 
  theme_map() %+replace% theme(legend.position =c(.5,.9),legend.direction="horizontal")

# 希拉里各州选票支持率统计：
qa<-quantile(na.omit(American_data$Clinton), c(0,0.2,0.4,0.6,0.8,1.0))
American_data$Clinton_q<-cut(American_data$Clinton,qa,labels=c("0-20%","20-40%","40-60%","60-80%", "80-100%"),include.lowest=TRUE)
ggplot(American_data,aes(long,lat,group=group,fill=Clinton_q))+
  geom_polygon(colour="white")+
  scale_fill_brewer(palette="Blues")+
  coord_map("polyconic") +
  guides(fill=guide_legend(reverse=TRUE,title=NULL))+ 
  theme_map() %+replace% theme(legend.position = c(0.80,0.05),legend.text.align=1) 

# 川普各州选票支持率统计：
qb <- quantile(na.omit(American_data$Trump),c(0,0.2,0.4,0.6,0.8,1.0))
American_data$Trump_q<-cut(American_data$Trump,qb,labels=c("0-20%","20-40%","40-60%","60-80%","80-100%"),include.lowest = TRUE)
ggplot(American_data,aes(long,lat,group=group,fill=Trump_q))+
  geom_polygon(colour="white")+
  scale_fill_brewer(palette="Reds")+
  coord_map("polyconic") +
  guides(fill=guide_legend(reverse=TRUE,title=NULL))+ 
  theme_map() %+replace% theme(legend.position = c(0.80,0.05),legend.text.align=1) 


# 下面是shiny仪表板的构建过程：

ui<-dashboardPage(
  dashboardHeader(title="Basic dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Electoral Vote",  tabName = "dashboard1",icon =icon("dashboard")),
      menuItem("Trump VS Clinton",tabName = "dashboard2",icon =icon("dashboard")),
      menuItem("Hillary's Vote",  tabName = "dashboard3",icon =icon("dashboard")),
      menuItem("Trump's Vote",    tabName = "dashboard4",icon =icon("dashboard")),
      menuItem("Widgets",         tabName = "widgets",  icon =icon("th"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard1",   
              fluidRow(
                box(title="Electoral Vote",plotOutput("plot1", width=1000, height=750),width =12)
              )
      ),
      tabItem(tabName = "dashboard2", 
              fluidRow(
                box(title="Trump VS Clinton",plotOutput("plot2", width=1000, height=750),width =12)
              )
      ),
      tabItem(tabName = "dashboard3",
              fluidRow(
                box(title="Hillary's Vote",plotOutput("plot3", width=1000, height=750),width =12)
              )
      ),
      tabItem(tabName = "dashboard4",
              fluidRow(
                box(title="Trump's Vote",plotOutput("plot4", width=1000, height=750),width =12)
              )
      ),
      tabItem(tabName="widgets",
              fluidRow(
                box(title =h2("About Detials"),h3("In 2016, Donald trump won 290 votes and Hillary Clinton won 228. Donald trump finally won, becoming the 45th President of the United States"),width =12)
              )
      )
    )
  )
)

# 构建服务端代码：
server <- shinyServer(function(input,output){
  output$plot1 <- renderPlot({
    ggplot()+
      geom_polygon(data=American_data,aes(x=long,y=lat,group=group),colour="grey",fill="white")+
      geom_point(data=mynewdata,aes(x=long,y=lat,size=Count,fill=Count),shape=21,colour="black")+
      scale_size_area(max_size=15)+ 
      scale_fill_gradient(low="white",high="#D73434")+
      coord_map("polyconic") +
      theme_map(base_size =15, base_family = "") %+replace% 
      theme(legend.position ="none")
  })
  output$plot2 <- renderPlot({
    ggplot(American_data,aes(x=long,y=lat,group=group,fill=Results))+
      geom_polygon(colour="white")+
      scale_fill_manual(values=c("#19609F","#CB1C2A"),labels=c("Hillary", "Trump"))+
      coord_map("polyconic") +
      guides(fill=guide_legend(title=NULL))+ 
      theme_map(base_size =15, base_family = "") %+replace% 
      theme(legend.position =c(.5,.9),legend.direction="horizontal")
  })
  output$plot3 <- renderPlot({
    qa<-quantile(na.omit(American_data$Clinton), c(0,0.2,0.4,0.6,0.8,1.0))
    American_data$Clinton_q<-cut(American_data$Clinton,qa,labels=c("0-20%","20-40%","40-60%","60-80%", "80-100%"),include.lowest=TRUE)
    ggplot(American_data,aes(long,lat,group=group,fill=Clinton_q))+
      geom_polygon(colour="white")+
      scale_fill_brewer(palette="Blues")+
      coord_map("polyconic") +
      guides(fill=guide_legend(reverse=TRUE,title=NULL))+ 
      theme_map(base_size = 15, base_family = "") %+replace% 
      theme(legend.position = c(0.80,0.05),legend.text.align=1)
  })
  output$plot4 <- renderPlot({
    qb <- quantile(na.omit(American_data$Trump),c(0,0.2,0.4,0.6,0.8,1.0))
    
    American_data$Trump_q <- cut(American_data$Trump,qb,labels=c("0-20%","20-40%","40-60%","60-80%","80-100%"),include.lowest = TRUE)
    
    ggplot(American_data,aes(long,lat,group=group,fill=Trump_q))+
      geom_polygon(colour="white")+
      scale_fill_brewer(palette="Reds")+
      coord_map("polyconic") +
      guides(fill=guide_legend(reverse=TRUE,title=NULL))+ 
      theme_map(base_size = 15, base_family = "") %+replace% 
      theme(legend.position = c(0.80,0.05),legend.text.align=1) 
  })
})

# 运行仪表盘：
shinyApp(ui, server)

