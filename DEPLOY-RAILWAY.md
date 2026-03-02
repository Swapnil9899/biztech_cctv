# Railway Deployment Guide

This guide will help you deploy your CCTV Dashboard to Railway so it can be accessed from any device 24/7, even when your laptop is off.

## Prerequisites

1. **GitHub Account** - You'll need to push your code to GitHub
2. **Railway Account** - Sign up at [railway.app](https://railway.app) using GitHub

## Step 1: Push Code to GitHub

1. Create a new repository on GitHub (e.g., `cctv-dashboard`)
2. Open terminal in the CCTV folder:
```
bash
cd ../OneDrive/Desktop/CCTV
git init
git add .
git commit -m "Prepare for Railway deployment"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/cctv-dashboard.git
git push -u origin main
```

## Step 2: Deploy to Railway

1. Go to [railway.app](https://railway.app) and sign in
2. Click **"New Project"**
3. Select **"Deploy from GitHub repo"**
4. Select your `cctv-dashboard` repository
5. Railway will auto-detect the `railway.json` configuration
6. Click **"Deploy"**

## Step 3: Get Your Public URL

1. Wait for deployment to complete (may take 2-3 minutes)
2. Once deployed, Railway will provide a URL like: `https://cctv-dashboard.up.railway.app`
3. This is your public link - share it with anyone!

## Important Notes

### Data Persistence
- The database file (`productivity.db`) is stored in the container
- **Note**: Railway's free tier containers may be stopped after inactivity
- To keep it running 24/7, you may need a paid plan or use the "Never Sleep" feature on hobby tier

### Alternative: Keep Your Local Server Running

If you don't want to use cloud hosting and prefer local access:

1. **Use a Raspberry Pi** or old PC as a home server
2. **Use ngrok** for temporary public access:
```
bash
# Install ngrok
winget install ngrok

# Start your dashboard locally, then:
ngrok http 3000
```

### For Permanent Cloud Deployment (Recommended)

For truly 24/7 access without container sleep issues:

1. **Railway Pro** - ~$5/month for always-on containers
2. **Render** - Free tier available, similar to Railway
3. **DigitalOcean** - Droplet starting at $4/month

## Testing Your Deployment

After deployment, visit your Railway URL:
- Frontend: `https://your-project-name.up.railway.app`
- API: `https://your-project-name.up.railway.app/api/dashboard`

## Troubleshooting

### Container Sleeping
If your app stops responding:
1. Check Railway dashboard for container status
2. Consider upgrading to keep container always running

### Database Reset
If data resets on each deploy:
1. Railway ephemeral disks reset on each deployment
2. Consider using Railway's persistent disk or a managed database

### Build Failures
Check the Railway deployment logs for specific errors. Common fixes:
- Ensure all files are pushed to GitHub
- Check `Dockerfile` syntax
- Verify `railway.json` is correct
