import de.bezier.guido.*;
//Declare and initialize constants NUM_ROWS and NUM_COLS = 20
private MSButton[][] buttons; //2d array of minesweeper buttons
public int NUM_ROWS = 20;
public int NUM_COLS = 20;
public int NUM_MINES = 80;
private ArrayList <MSButton> mines = new ArrayList <MSButton>(); //ArrayList of just the minesweeper buttons that are mined

public boolean gameLost = false;
public boolean firstClick = true;
public int t = 500;

void setup ()
{
  size(800, 900);
  textAlign(CENTER, CENTER);

  // make the manager
  Interactive.make( this );

  //your code to initialize buttons goes here
  buttons = new MSButton [NUM_ROWS][NUM_COLS];
  for (int r = 0; r < NUM_ROWS; r++)
    for (int c = 0; c < NUM_COLS; c++)
      buttons [r][c] = new MSButton (r, c);
  setMines();
}
public void setMines()
{
  while (mines.size() > 0) {
    mines.remove(0);
  }
  int tempr, tempc;
  while (mines.size() < NUM_MINES) {
    tempr = (int)(Math.random()*NUM_ROWS);
    tempc = (int)(Math.random()*NUM_COLS);
    if (!(mines.contains(buttons[tempr][tempc]))) {
      mines.add(buttons[tempr][tempc]);
    }
  }
}

public void draw ()
{
  background( 0 );
  if (isWon() == true)
    displayWinningMessage();
  if(!gameLost && !isWon()){
    t--;
    if(t<0){
      move();
      t=500;
    }
  }
  ui();
}
public boolean isWon()
{
  for (int r = 0; r < NUM_ROWS; r++)
    for (int c = 0; c < NUM_COLS; c++)
      if (!buttons[r][c].isClicked() && !mines.contains(buttons[r][c]))
        return false;
  return true;
}
public void displayLosingMessage()
{
  for (int i = 0; i < mines.size(); i++) {
    if (!mines.get(i).isClicked()){
      mines.get(i).setClicked(true);
    }
  }
}
public void displayWinningMessage()
{

}
public boolean isValid(int row, int col)
{
  boolean ans = false;
  if (row < NUM_ROWS && col < NUM_COLS && row >= 0 && col >= 0) {
    ans = true;
  }
  return ans;
}
public int countMines(int row, int col)
{
  int numMines = 0;
  for (int r = row-1; r <= row+1; r ++)
    for (int c = col-1; c <= col +1; c ++)
      if (isValid (r, c) && mines.contains(buttons [r][c]) && !(r == row && c == col))
        numMines++;
  return numMines;
}
public class MSButton
{
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged;
  private String myLabel;

  public MSButton ( int row, int col )
  {
    width = 800/NUM_COLS;
    height = 800/NUM_ROWS;
    myRow = row;
    myCol = col; 
    x = myCol*width;
    y = myRow*height;
    myLabel = "";
    flagged = clicked = false;
    Interactive.add( this ); // register it with the manager
  }

  // called by manager
  public void mousePressed () 
  {
    if (!gameLost && !isWon()) {
      if (!firstClick) {
        clicked = true;
        if (mouseButton == RIGHT && (myLabel == "" || myLabel == "M")) {
          flagged = !flagged;
          if (!flagged)
            clicked = false;
          if(!mines.contains(buttons [myRow][myCol])){
            displayLosingMessage();
            gameLost = true;
          }
        } else if (mines.contains(buttons [myRow][myCol]) && !flagged) {
          displayLosingMessage();
          gameLost = true;
        } else if (countMines(myRow, myCol)>0) {
          setLabel(countMines(myRow, myCol));
        } else {
          setLabel(" ");
          for (int r = myRow -1; r <= myRow+1; r++)
            for (int c = myCol -1; c <= myCol+1; c++)
              if (isValid(r, c) && !buttons[r][c].isClicked())
                buttons[r][c].mousePressed();
        }
      } else {
        firstClick = false;
        while (countMines(myRow, myCol)>0 || mines.contains(buttons[myRow][myCol])) {
          setMines();
        }
        clicked = true;
        setLabel(" ");
        for (int r = myRow -1; r <= myRow+1; r++)
          for (int c = myCol -1; c <= myCol+1; c++)
            if (isValid(r, c) && !buttons[r][c].isClicked())
              buttons[r][c].mousePressed();
      }
    }
  }
  public void draw () 
  {    
    if (flagged)
      fill(0);
    else if ( clicked && mines.contains(this) ) 
      fill(255, 0, 0);
    else if (clicked)
      fill( 200 );
    else 
    fill( 100 );
    textAlign(CENTER, CENTER);
    rect(x, y, width, height);
    fill(0);
    textSize(width/2);
    text(myLabel, x+width/2, y+height/2);
  }
  public void setLabel(String newLabel)
  {
    myLabel = newLabel;
  }
  public void setLabel(int newLabel)
  {
    myLabel = ""+ newLabel;
  }
  public boolean isFlagged()
  {
    return flagged;
  }
  public boolean isClicked()
  {
    return clicked;
  }
  public void setClicked(boolean newClick)
  {
    clicked = newClick;
  }
}
public void move()
{
  for (int i = mines.size()-1; i >= 0; i--) {
    if (!mines.get(i).isFlagged()) {
      mines.remove(i);
    }
  }
  while (mines.size() < NUM_MINES) {
    int tempr, tempc;
    while (mines.size() < NUM_MINES) {
      tempr = (int)(Math.random()*NUM_ROWS);
      tempc = (int)(Math.random()*NUM_COLS);
      if (!(mines.contains(buttons[tempr][tempc])) && !buttons[tempr][tempc].isClicked()) {
        mines.add(buttons[tempr][tempc]);
      }
    }
  }
  for (int r = 0; r < NUM_ROWS; r++) {
    for (int c = 0; c < NUM_COLS; c++) {
      buttons[r][c].setLabel("");
      if (buttons[r][c].isClicked() && !mines.contains(buttons[r][c])) {
        if (countMines(r, c)>0) {
          buttons[r][c].setLabel(countMines(r, c));
        } else {
          buttons[r][c].setLabel(" ");
          buttons[r][c].mousePressed();
        }
      }
      if (mines.contains(buttons[r][c])) {
        //buttons[r][c].setLabel("M");
      }
    }
  }
}
public void ui(){
  fill(255, 255, 255);
  textSize(25);
  textAlign(LEFT, CENTER);
  text("Time to next shift: " + t, 15, 850);
  textAlign(RIGHT,CENTER);
  if(isWon()){
    text("Congratulations! You Won! :)", 785, 850);
  }
  if(gameLost){
    text("You Lost :(", 785, 850);
  }
}


