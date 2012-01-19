/*******************************************

LineSegBody with general motions

********************************/

class GenMotionBody extends LineSegBody{
  ArrayList<PVector> coordsDx;
  
  GenMotionBody( float xc, float yc, float[] x, float[] y , Window window ){
    super(xc,yc,window);
    coordsDx = new ArrayList();
    for( int i=0; i<x.length; i++ ){
      add(x[i],y[i]);
      coordsDx.add(new PVector(0,0));
    }
    end();
  }
  
  void update( float[] x, float[] y ){
    update();
    for( int i=0; i<n; i++ ) {
      PVector x0 = coords.get(i);
      PVector x1 = new PVector(x[i],y[i]);
      coords.set(i,x1);
      coordsDx.set(i,PVector.sub(x1,x0));
    }
    end();
    unsteady = true;
  }
  
  int closest( float x, float y ){
    int j=0; 
    float dis = orth[j].distance(x,y);
    for( int i=1; i<n-1; i++ ){
      float d = orth[i].distance(x,y);
      if(d<dis) {j=i; dis=d;}
    }
    return j;
  }
    
  float velocity( int d, float dt, float x, float y ){
    float velo = super.velocity(d,dt,x,y);
    // add the velocity of the nearest segment
    int i = closest(x,y);
    PVector dx0 = coordsDx.get(i), dx1 = coordsDx.get(i+1);
    if(d==1) return velo+0.5*(dx0.x+dx1.x)/dt;
    else     return velo+0.5*(dx0.y+dx1.y)/dt;
  }
}
