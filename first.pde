
class Slider2{
	int posx, posy, wid, hei, g_value;
	float g_buttonx, g_buttony, g_min, g_max, radius, value_min, value_max, l_value;
	PVector _color;
	String name;
	Slider2(String kname, int kposx, int kposy, int kwid, int khei, float kmin, float kmax, float value, PVector kcolor){
		posx = kposx;
		posy = kposy;
		wid = kwid;
		hei = khei;
    	l_value = value;
		value_min = kmin;
		value_max = kmax;
		g_min = posx + wid/20;
		g_max = posx + wid - wid/20;
		g_value = int(g_min) + int(l_value);
		g_buttonx = g_min + l_value;
		g_buttony = posy + hei/2;
		radius = hei/2;
		_color = kcolor;
		name = kname;
	}
	void show(){
		fill(255, 255, 255);
		rect(posx, posy, wid, hei);
		fill(_color.x, _color.y, _color.z);
		rect(g_min, posy+hei/4, l_value, hei-hei/4*2);
		fill(255, 0, 0);
		circle(g_buttonx, g_buttony, radius);
		fill(0, 0, 0, 255);
		String ddd = new String(str(map(g_value, g_min, g_max, value_min, value_max)));
		text(name+":"+ddd, g_min, posy+hei/2);

	}
	void grab(){
		if (dist(mouseX, mouseY, g_buttonx, g_buttony) < radius && mousePressed){
			g_value = mouseX;
			if (g_value < g_min){
				g_value = int(g_min);
			} else if (g_value > g_max){
				g_value = int(g_max);
			}
		}

	}
	void update(){
		l_value = g_value - int(g_min);
		g_buttonx = g_value;

	}
	float get_value(){
		return map(g_value, g_min, g_max, value_min, value_max);
	}

}

class Boid{
  	PVector vel, acc, pos;
  	int scl, me;
	float max_force = 0.04;
    Boid(int meret, int ind){
        pos = new PVector(random(width), random(width));
        acc = new PVector(0, 0);
        vel = PVector.random2D();
        scl = meret;
        me = ind;
		max_force = 0.02;
        
    }
    void show(){
        push();
        fill(255, 255, 255);
        translate(pos.x, pos.y);
        rotate(vel.heading());
        triangle(-scl*1.5, scl/2, -scl*1.5, -scl/2, 0, 0);	
        pop();
    }

    void update(){
		vel.setMag(1.4);
		pos.add(vel);
		vel.add(acc);
    	acc.mult(0);
    }
    void edge(){
		if (pos.x > width){pos.x = 0;}
		else if (pos.x < 0){pos.x = width;}
		if (pos.y > height){pos.y = 0;}
		else if (pos.y < 0){pos.y = height;}
    }

    void align(ArrayList<Integer> list, float mag){
		if (list.size() > 0){
			PVector atlag = new PVector(0, 0);
			for (int index = 0; index < list.size(); index++){
				atlag.add(boids[list.get(index)].vel);
			}
			atlag.div(list.size());
			PVector force = atlag.sub(vel);
			force.limit(max_force);
			force.setMag(mag);
			acc.add(force);
		}
    }

	void separation(ArrayList<Integer> list, float force){
		if (list.size() > 0){
			PVector atlag = new PVector(0, 0);
			int total = 0;
			Boid[] objects = new Boid[list.size()];
			for (int i = 0; i < list.size(); i++){
				objects[i] = boids[list.get(i)];
			}
			for (int i = 0; i < objects.length; i++){
				PVector vec = PVector.sub(pos, objects[i].pos);
        		vec.div(dist(pos.x, pos.y, objects[i].pos.x, objects[i].pos.y));
				atlag.add(vec);
				total++;
			}
			if (total > 0){
				atlag.div(total);
				atlag.sub(vel);
				atlag.limit(max_force);
				atlag.setMag(force);
        		acc.add(atlag);
			}
		}
	}
	ArrayList<Integer> neighbour(int radius){
		ArrayList<Integer> list = new ArrayList<Integer>();
		for (int they = 0; they < boids.length; they++){
        	if (they != me){
				Boid other = boids[they];
				if (dist(pos.x, pos.y, other.pos.x, other.pos.y) < radius){
					list.add(they);
				}	
        	}

		}
		return list;
	}

	void cohesion(ArrayList<Integer> list, float mag){
		PVector atlag = new PVector(0, 0);
		int total = 0;
		for (int i = 0; i < list.size(); i++){
			atlag.add(boids[list.get(i)].pos);
			total++;
		}
		if (total > 0){
			atlag.div(total);
			PVector force = PVector.sub(atlag, pos);
			force.limit(max_force);
			force.setMag(mag);
			acc.add(force);
		}
	}
}	


int db = 300;
Boid[] boids = new Boid[db];
Slider2[] sliders = new Slider2[6];
Slider2 align = new Slider2("align", 30, 30, 200, 30, 0, 200, 30, new PVector(60, 70, 255));
Slider2 cohesion = new Slider2("cohesion", 300, 30, 200, 30, 0, 200, 30, new PVector(70, 255, 70));
Slider2 separation = new Slider2("separation", 600, 30, 200, 30, 0, 200, 30, new PVector(255, 70, 60));
Slider2 align_force = new Slider2("align force", 30, 70, 200, 30, 0, 0.1, 0.02, new PVector(255, 255, 60));
Slider2 cohesion_force = new Slider2("cohesion force", 300, 70, 200, 30, 0, 0.1, 0.02, new PVector(255, 255, 60));
Slider2 separation_force = new Slider2("separation force", 600, 70, 200, 30, 0, 0.1, 0.02, new PVector(255, 255, 60));

void setup(){
	fullScreen();
	sliders[0] = align;
	sliders[1] = cohesion;
	sliders[2] = separation;
	sliders[3] = align_force;
	sliders[4] = cohesion_force;
	sliders[5] = separation_force;

	for (int i = 0; i<db; i++){
		boids[i] = new Boid(10, i);
	}
}

float align_perc = 30;
float cohesion_perc = 30;
float separation_perc = 30;

void draw(){
	background(30, 30, 30);
	for (int all = 0; all<boids.length; all++){
		boids[all].align(boids[all].neighbour(int(align_perc)), align_force.get_value());
		boids[all].cohesion(boids[all].neighbour(int(cohesion_perc)), cohesion_force.get_value());
		boids[all].separation(boids[all].neighbour(int(separation_perc)), separation_force.get_value());
		boids[all].update();
		boids[all].edge();
		boids[all].show();
	}
	for (int slid = 0; slid<sliders.length; slid++){
		sliders[slid].grab();
		sliders[slid].update();
		sliders[slid].show();
	}
	align_perc = sliders[0].get_value();
	cohesion_perc = sliders[1].get_value();
	separation_perc = sliders[2].get_value();
}

void keyPressed(){
	circle(width/2, height/2, 200);
	if (key == ESC || keyCode == ESC){
			print("ok\n");
			exit();
		}
}
