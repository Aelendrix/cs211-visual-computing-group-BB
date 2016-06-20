class DataViewer
{
  PGraphics dataBackground;
  PGraphics topView;
  PGraphics scoreBoard;
  PGraphics barChart;
  //beige
  PVector colorBack = new PVector(12*16, 12*16, 6*16);
  //blue
  PVector colorTop = new PVector(0, 4*16+1, 12*16+2);
  int heightData;
  int space;
  int textSize = 10;
  float newPlanSize;
  float ballR;
  float cylinderR;
  
  int cubeSize=5;
  

  DataViewer() {

    heightData = 100;
    space = 5;
    newPlanSize = heightData-space*2;
    ballR = sphereR*newPlanSize * 2 / planX;
    cylinderR = cylinderBaseSize * newPlanSize * 2 / planX;
    
    dataBackground = createGraphics(width, heightData, P2D);
    dataBackground.beginDraw();
    dataBackground.background(colorBack.x, colorBack.y, colorBack.z);
    dataBackground.endDraw();
    
    scoreBoard = createGraphics(heightData*3/4, heightData, P2D);
    scoreBoard.textFont(createFont("Arial", textSize));
    
    topView = createGraphics(heightData-2*space, heightData-2*space, P2D);
    
    barChart = createGraphics(width-2*heightData,heightData*2/3,P2D);
  }
  void updateTopView() {
    //update topView
    topView.beginDraw();
    topView.background(colorTop.x, colorTop.y, colorTop.z);
    for (int i=0; i<cylinderPos.size(); i++)
    {
      //map the cylinders on the topView
      topView.fill(colorBack.x, colorBack.y, colorBack.z);
      topView.stroke(0);
      topView.ellipse(mapping(cylinderPos.get(i).x), mapping(cylinderPos.get(i).y), cylinderR, cylinderR);
    }
    //map the ball on the topView
    topView.noStroke();
    topView.fill(255);
    topView.ellipse(mapping(mover.pos().x), mapping(mover.pos().z), ballR, ballR);
    topView.endDraw();
  }
   void updateScoreBoard(float v){
     oldScore=score;
     score+=v;
    //update scoreBoard
    scoreBoard.beginDraw();
    //scoreBoard.background(100);
    scoreBoard.background(colorBack.x,colorBack.y,colorBack.z);
    scoreBoard.stroke(255);
    scoreBoard.noFill();
    scoreBoard.rect(0, 0, heightData*3/4-1, heightData-space-1);
    scoreBoard.fill(0);
    scoreBoard.textSize(textSize);
    scoreBoard.text("Total Score:", space, space*3);  
    scoreBoard.text(""+score, space, space*3+textSize);
    scoreBoard.text("Velocity:", space, space*3+heightData*1/3);
    scoreBoard.text(""+mover.ballVelocity.mag(), space, space*3+heightData*1/3+textSize);
    scoreBoard.text("Last Score:", space, space*3+heightData*2/3);
    scoreBoard.text(""+oldScore, space, space*3+heightData*2/3+textSize);
    scoreBoard.endDraw(); 
  }
  //Helper function to map on specific parameter
  float mapping(float t)
  {
    return map(t, -planX/2, planX/2, 0, newPlanSize);
  }
  
  void updateBarChart()
  {
    scoreArray.add(score);
    barChart.beginDraw();
    barChart.background(255);
    barChart.fill(colorTop.x,colorTop.y,colorTop.z);
    barChart.stroke(255);

    for(int i=0;i<scoreArray.size();i++)
    {
      int k = (int)(double)scoreArray.get(i)/2;
      for(int j=0;j<k;j++)
      {
      barChart.rect(cubeSize*i,+heightData*2/3-cubeSize*(j+1),cubeSize,cubeSize);
      }
    }
    barChart.endDraw();
  }


  void display() {
    image(dataBackground, 0, width-heightData);
    image(topView, space, width-heightData+space);
    image(scoreBoard, space/2+heightData+space*2, width+space/2-heightData);
    image(barChart, space*2+heightData*7/4+space*2,width+space/2-heightData);
  }
}