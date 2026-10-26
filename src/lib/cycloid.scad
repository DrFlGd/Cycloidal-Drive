// Cycloid disc profile: pin-centre epitrochoid, inward roller offset and curvature-weighted
// resampling. Pure functions first, then the profile of the current configuration.
// Included by cycloidal_gearbox.scad.

// Pin-centre epitrochoid in the disc frame (A = ring pitch radius, E = eccentricity,
// N = lobes, so N+1 ring rollers) and its derivatives with respect to t in radians.
function cyc_base(t,A,E,N)=[A*cos(t)-E*cos((N+1)*t), A*sin(t)-E*sin((N+1)*t)];
function cyc_d1(t,A,E,N)=[-A*sin(t)+E*(N+1)*sin((N+1)*t), A*cos(t)-E*(N+1)*cos((N+1)*t)];
function cyc_d2(t,A,E,N)=[-A*cos(t)+E*(N+1)*(N+1)*cos((N+1)*t), -A*sin(t)+E*(N+1)*(N+1)*sin((N+1)*t)];
// Signed radius of curvature of the base curve: positive where it turns toward the disc centre.
function cyc_rho(t,A,E,N)=let(d1=cyc_d1(t,A,E,N),d2=cyc_d2(t,A,E,N),cr=d1[0]*d2[1]-d1[1]*d2[0]) cr==0 ? 1e9 : pow(norm(d1),3)/cr;
// Disc profile = base curve offset inward by the roller radius plus clearance (the envelope of the rollers).
function cycloid_point(t,A,E,Rp,N)=let(b=cyc_base(t,A,E,N),d=cyc_d1(t,A,E,N),n=d/norm(d)) [b[0]-Rp*n[1], b[1]+Rp*n[0]];
// Curvature-weighted resampling: output points are spaced so every chord has about the
// same sagitta (chord^2 / 8 rho), instead of equal steps of t that cluster on the lobe
// tips and starve the valleys where the rollers actually contact.
function cyc_dense(A,E,Rp,N,m)=[for(i=[0:m-1]) cycloid_point(360*i/m,A,E,Rp,N)];
function cyc_weights(P,A,E,N,Rp,m)=[for(i=[0:m-1]) let(j=(i+1)%m, rho=abs(cyc_rho(360*(i+0.5)/m,A,E,N)-Rp)) norm(P[j]-P[i])/sqrt(max(rho,0.3))];
function cumsum_before(w)=[for(i=0,s=0; i<len(w); s=s+w[i], i=i+1) s];
function lower_bound(L,s,lo,hi)= hi-lo<=1 ? lo : let(mid=floor((lo+hi)/2)) (L[mid]<=s ? lower_bound(L,s,mid,hi) : lower_bound(L,s,lo,mid));
function cyc_resample(P,W,total,res)=let(m=len(P)) [for(k=[0:res-1]) let(s=total*k/res, i=lower_bound(W,s,0,m), j=(i+1)%m, w0=W[i], w1=(i+1<m?W[i+1]:total), f=(w1>w0)?(s-w0)/(w1-w0):0) P[i]+(P[j]-P[i])*f];
function cycloid_profile(A,E,Rp,N,res,mult)=
    let(m=res*mult, P=cyc_dense(A,E,Rp,N,m), w=cyc_weights(P,A,E,N,Rp,m), W=cumsum_before(w), total=W[m-1]+w[m-1])
    cyc_resample(P,W,total,res);
cycloid_points=cycloid_profile(ring_pitch_r,eccentricity,ring_roller_r_for_profile,lobes,profile_resolution,profile_dense_multiplier);
// Estimated worst facet error of the polygon (uniform by construction).
cycloid_facet_error=let(m=profile_resolution*profile_dense_multiplier,
    P=cyc_dense(ring_pitch_r,eccentricity,ring_roller_r_for_profile,lobes,m),
    w=cyc_weights(P,ring_pitch_r,eccentricity,lobes,ring_roller_r_for_profile,m),
    total=sum_list(w)) pow(total/profile_resolution,2)/8;
function sum_list(v,i=0,acc=0)= i>=len(v) ? acc : sum_list(v,i+1,acc+v[i]);
// Smallest convex radius of the base curve; the inward offset Rp must stay below it or the
// profile undercuts (the offset curve folds back on itself at the lobe tips).
cycloid_undercut_samples=720;
cycloid_min_convex_rho=min([for(i=[0:cycloid_undercut_samples-1]) let(r=cyc_rho(360*i/cycloid_undercut_samples,ring_pitch_r,eccentricity,lobes)) r>0 ? r : 1e9]);
