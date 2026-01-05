# User Interface Screenshots

This folder contains screenshots of the user-facing screens of the Smart Waste Collection App.

## Required Screenshots

### 1. **home_dashboard.png**
Main user home screen showing:
- Greeting message "Good Afternoon 👋 Rajaswamy"
- Eco Tip of the Day card with orange icon
- Statistics section with three metrics:
  - 0 Pending (clock icon)
  - 0 Active (truck icon)
  - 0 Completed (checkmark icon)
  - 0% Completion Rate
- Waste Categories section with three cards:
  - Organic (green) - Food scraps, leaves, garden waste
  - Recyclable (blue) - Paper, plastic, glass, metal
  - E-Waste (pink) - Electronics, batteries, cables

### 2. **home_scrolled.png**
Home screen scrolled down showing:
- Waste category cards at top
- "How Recycling Works" section with "Learn More" link
- Organic Waste card showing:
  - "Reduces methane by 60%" badge
  - Process flow: Collect → Sort → Compost → Fertilizer
  - Result description: "Food scraps and garden waste become nutrient-rich compost for farming"
  - Carousel dots (4 slides)
- "Your Pickups" section with tabs:
  - All (active)
  - Active
  - Completed
- Empty state: "No pickup requests" with trash icon
- Green "New Pickup" button

### 3. **activity_stats.png**
Dedicated activity and rewards screen showing:
- Activity Stats card with three metrics:
  - 0 Total Pickups
  - 0kg CO₂ Saved
  - 0 Eco Score
- Eco Rewards section featuring:
  - Next Reward: ₹25 Grocery Voucher (0 pts, needs 20 points)
  - Progress bar
- Locked reward tiers:
  - Eco Starter (20 pts): ₹25 Grocery Voucher - Local grocery stores
  - Green Champion (50 pts): ₹75 Shopping Coupon - Partner retail stores
  - Eco Warrior (100 pts): ₹150 Home Essentials Kit - Eco-friendly products
  - Earth Guardian (200 pts): ₹300 + Free Month Service - Premium package

### 4. **profile.png**
User profile screen displaying:
- Large circular avatar with "R" initial and camera icon
- Name: "Rajaswamy"
- Role badge: "USER"
- Account Information:
  - Email: rs8523@gmail.com (Verified)
  - Full Name: Rajaswamy
- Contact Details:
  - Phone Number: 8148155805
  - Address: Trichy
- Activity Stats preview (3 metrics at bottom)

### 5. **settings.png**
Settings screen with:
- Header: "Settings - Manage your preferences"
- Account section:
  - User card with avatar, name, email, and USER badge
  - Edit Profile option
- Preferences section:
  - Dark Mode toggle (off)
  - Notifications toggle (on)
  - Location Services toggle (on)
- Support section header

### 6. **settings_support.png**
Settings scrolled to show support options:
- Location Services toggle at top
- Support section with:
  - Help & Support - "FAQs and customer support"
  - About - "App version and information"
  - Privacy Policy - "Read our privacy policy"
  - Terms of Service - "Read our terms and conditions"
- Logout button (red)
- App branding at bottom:
  - Green leaf icon
  - "Eco Waste"
  - Version 1.0.0
  - 🌍 "Making the planet cleaner, one pickup at a time"

### 7. **request_pickup.png**
Request pickup form showing:
- Header: "Request Pickup - Schedule your waste collection"
- Select Waste Type:
  - Organic (selected, green border with checkmark)
  - Recyclable
  - E-Waste
  - Info banner: "Food waste, garden waste, biodegradables"
- Quantity field with placeholder: "e.g., 2 bags, 5kg, 1 box"
- Schedule section:
  - Date picker: Mon, Jan 5
  - Time picker: 9:00 AM
- Pickup Address:
  - "Use profile address" checkbox (checked)
  - Address display: Trichy with location icon
  - "Pick from Map" button (green outlined)

## File Naming Convention

```
home_dashboard.png
home_scrolled.png
activity_stats.png
profile.png
settings.png
settings_support.png
request_pickup.png
```

## Image Specifications

- **Format**: PNG
- **Resolution**: 1170 x 2532 pixels (iPhone screenshots)
- **Quality**: High quality, retina display
- **Background**: Actual app screenshots
- **Status Bar**: Include with time, signal, battery

## How to Add Screenshots

### Option 1: From Device/Simulator
1. Take screenshots of each screen
2. Transfer to your Mac
3. Rename according to convention above
4. Copy to `/Users/rajaswamy.s/Waste/smart_waste_app/screenshots/user/`

### Option 2: Using Terminal
```bash
cd /Users/rajaswamy.s/Waste/smart_waste_app/screenshots/user/

# If screenshots are in Downloads
cp ~/Downloads/IMG_XXXX.PNG home_dashboard.png
cp ~/Downloads/IMG_YYYY.PNG home_scrolled.png
# ... and so on

# Commit to git
git add *.png
git commit -m "Add user interface screenshots"
git push origin main
```

### 8. **how_recycling_works.png**
Dedicated "How Recycling Works" screen showing:
- Full recycling process visualization
- Organic Waste process with complete flow:
  - Collect → Sort → Compost → Fertilizer
- Result card with tractor icon:
  - "Organic Fertilizer"
  - "Food scraps and garden waste become nutrient-rich compost for farming"
- Carousel indicators showing multiple waste types
- "Learn More" button

### 9. **notifications.png**
Notifications screen displaying:
- Header: "Notifications - 0 unread"
- Tabs: "Unread" (active) and "All"
- Empty state with notification icon
- Message: "No unread notifications"

### 10. **app_guide.png**
App onboarding guide showing how the service works:
- Header: "App Guide"
- 5-step process with numbered cards:
  1. **Create Account** - Sign up with email and phone
  2. **Request Pickup** - Select waste type, quantity, schedule
  3. **Collector Assigned** - Nearby collector assigned to request
  4. **Waste Collected** - Collector picks up waste at scheduled time
  5. **Recycled & Processed** - Waste responsibly recycled/disposed
- "Have Feedback?" section with Send Feedback button

### 11. **pickup_details_tracking.png**
Pickup details and tracking screen:
- Header: "Organic - Quantity: 2"
- Current Status: "Live" (ASSIGNED status)
- Status timeline showing:
  - Requested (completed)
  - Assigned (completed)
  - On the Way (upcoming)
  - Collected (upcoming)
- Schedule section:
  - Date: Mon, Jan 05, 2026
  - Time: MORNING
- Pickup Location:
  - Address: Trichy (with location pin)
  - Map view showing pickup location
  - Directions button

### 12. **pickup_details_collector.png**
Pickup details showing assigned collector:
- Schedule and location information
- Collector section:
  - Name: Sanjay Raam
  - Role: Waste Collector
  - Phone call button (green)
- Request ID and creation time
- Status: Live with "ASSIGNED" badge

### 13. **ecobot_assistant.png**
EcoBot chatbot assistant screen:
- Header: "EcoBot - Online"
- Welcome message from EcoBot:
  - "Hello! 👋 I'm EcoBot, your Smart Waste Collection assistant"
  - Features: Scheduling pickups, tracking requests, eco points & rewards, waste types & recycling, account issues
- Question: "How can I help you today?"
- Quick action buttons:
  - Schedule pickup
  - Track my order
  - Eco points
  - Contact support
- Message input field at bottom

## File Naming Convention

```
home_dashboard.png
home_scrolled.png
how_recycling_works.png
profile.png
activity_stats.png
settings.png
settings_support.png
notifications.png
request_pickup.png
```

## Image Specifications

- **Format**: PNG
- **Resolution**: 1170 x 2532 pixels (iPhone screenshots)
- **Quality**: High quality, retina display
- **Background**: Actual app screenshots
- **Status Bar**: Include with time, signal, battery

## Current Status

✅ **Screenshots Captured**: 9 screens
✅ **Files Added**: home_dashboard.png, home_scrolled.png, how_recycling_works.png, profile.png, activity_stats.png, settings.png, settings_support.png, notifications.png, request_pickup.png
✅ **Documentation**: Updated and complete
✅ **Ready for Push**: Committed to git
