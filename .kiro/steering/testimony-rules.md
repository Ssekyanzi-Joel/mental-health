---
inclusion: always
---

# Testimony Management Rules

## Overview

This document defines the rules and guidelines for managing testimonies in the mental health application. Testimonies are sensitive user-generated content that require careful handling, moderation, and privacy protection.

## Core Principles

### 1. Privacy & Anonymity

- **Default Anonymity**: All testimonies should be anonymous by default
- **No Personal Information**: Never include real names, locations, or identifying details
- **User Consent**: Explicit consent required before publishing any testimony
- **Data Protection**: Follow GDPR/HIPAA guidelines for sensitive health information

### 2. Content Moderation

- **Pre-Publication Review**: All testimonies must be reviewed before going live
- **Content Guidelines**: No harmful, triggering, or inappropriate content
- **Professional Oversight**: Mental health professionals should review sensitive content
- **Flagging System**: Users can report inappropriate testimonies

### 3. Technical Implementation

#### Database Structure

```dart
// Firestore collection: 'testimonies'
{
  'id': String,                    // Auto-generated document ID
  'text': String,                  // Testimony content (required)
  'mediaUrl': String?,             // Optional image/video URL
  'mediaPath': String?,            // Firebase Storage path
  'isVideo': bool,                 // Media type indicator
  'authorType': String,            // 'user', 'therapist', 'admin'
  'authorId': String?,             // Reference to author (for moderation)
  'status': String,                // 'pending', 'approved', 'rejected'
  'moderatedBy': String?,          // Admin/therapist who reviewed
  'moderationNotes': String?,      // Internal moderation notes
  'isAnonymous': bool,             // Default: true
  'displayName': String?,          // Optional display name (not real name)
  'tags': List<String>,            // Categories: 'recovery', 'therapy', 'support'
  'helpfulCount': int,             // User engagement metric
  'reportCount': int,              // Flagging counter
  'createdAt': Timestamp,          // Creation timestamp
  'publishedAt': Timestamp?,       // Publication timestamp
  'updatedAt': Timestamp,          // Last modification
}
```

#### Validation Rules

```dart
class TestimonyValidator {
  static const int MIN_TEXT_LENGTH = 10;
  static const int MAX_TEXT_LENGTH = 1000;
  static const int MAX_MEDIA_SIZE_MB = 10;

  static bool validateTestimony(Map<String, dynamic> data) {
    // Text validation
    final text = data['text'] as String?;
    if (text == null || text.trim().length < MIN_TEXT_LENGTH) {
      return false;
    }
    if (text.length > MAX_TEXT_LENGTH) {
      return false;
    }

    // Content safety check
    if (containsInappropriateContent(text)) {
      return false;
    }

    return true;
  }

  static bool containsInappropriateContent(String text) {
    // Implement content filtering logic
    final prohibitedWords = ['suicide', 'self-harm', 'violence'];
    return prohibitedWords.any((word) =>
      text.toLowerCase().contains(word.toLowerCase()));
  }
}
```

### 4. User Interface Guidelines

#### Submission Form

- **Clear Guidelines**: Display content guidelines prominently
- **Character Counter**: Show remaining characters (max 1000)
- **Preview Mode**: Allow users to preview before submission
- **Consent Checkbox**: Explicit consent for publication
- **Anonymous Option**: Default to anonymous, allow opt-in for display name

#### Display Rules

- **Responsive Grid**: Use adaptive grid layout for different screen sizes
- **Loading States**: Show proper loading indicators
- **Error Handling**: Graceful error messages for failed uploads
- **Accessibility**: Proper alt text for images, screen reader support

### 5. Moderation Workflow

#### Admin/Therapist Dashboard

```dart
// Moderation interface requirements
class ModerationDashboard {
  // Show pending testimonies
  // Bulk approval/rejection actions
  // Search and filter capabilities
  // Moderation history tracking
  // User reporting system
}
```

#### Status Management

- **Pending**: Newly submitted, awaiting review
- **Approved**: Reviewed and approved for publication
- **Rejected**: Rejected with reason provided to author
- **Flagged**: Reported by users, needs re-review
- **Archived**: Removed from public view but kept for records

### 6. Security Measures

#### File Upload Security

```dart
class MediaUploadSecurity {
  static const List<String> ALLOWED_IMAGE_TYPES = [
    'image/jpeg', 'image/png', 'image/webp'
  ];

  static const List<String> ALLOWED_VIDEO_TYPES = [
    'video/mp4', 'video/webm'
  ];

  static bool validateFileType(String mimeType) {
    return ALLOWED_IMAGE_TYPES.contains(mimeType) ||
           ALLOWED_VIDEO_TYPES.contains(mimeType);
  }

  static bool validateFileSize(int bytes) {
    return bytes <= (10 * 1024 * 1024); // 10MB limit
  }
}
```

#### Storage Rules

- **Organized Structure**: `/testimonies/{year}/{month}/{filename}`
- **Access Control**: Proper Firebase Security Rules
- **Backup Strategy**: Regular backups of approved testimonies
- **Retention Policy**: Define how long to keep rejected testimonies

### 7. User Experience Rules

#### Feedback System

- **Submission Confirmation**: Clear success message after submission
- **Status Updates**: Notify users when testimony is approved/rejected
- **Helpful Voting**: Allow users to mark testimonies as helpful
- **Search & Filter**: Enable users to find relevant testimonies

#### Performance Optimization

- **Lazy Loading**: Load testimonies progressively
- **Image Optimization**: Compress images before upload
- **Caching Strategy**: Cache approved testimonies locally
- **Offline Support**: Allow viewing cached testimonies offline

### 8. Analytics & Monitoring

#### Key Metrics

- Submission rate and approval rate
- User engagement (views, helpful votes)
- Content categories and trends
- Moderation response times
- User satisfaction scores

#### Monitoring Alerts

- High rejection rates (may indicate unclear guidelines)
- Unusual submission patterns
- Media upload failures
- User reports requiring immediate attention

### 9. Legal & Compliance

#### Content Ownership

- Users retain ownership of their testimonies
- Platform has license to display approved content
- Clear terms of service regarding content usage
- Right to request removal of published testimonies

#### Data Protection

- Encrypt sensitive data at rest and in transit
- Regular security audits
- User data export capabilities
- Compliance with local privacy laws

### 10. Implementation Checklist

#### Phase 1: Core Functionality

- [ ] Basic testimony submission form
- [ ] Firebase integration for storage
- [ ] Admin moderation interface
- [ ] Content validation rules
- [ ] Basic display grid

#### Phase 2: Enhanced Features

- [ ] Media upload with validation
- [ ] User notification system
- [ ] Search and filtering
- [ ] Helpful voting system
- [ ] Reporting mechanism

#### Phase 3: Advanced Features

- [ ] Analytics dashboard
- [ ] Automated content screening
- [ ] Advanced moderation tools
- [ ] Performance optimizations
- [ ] Accessibility improvements

## Best Practices

1. **Always prioritize user safety and privacy**
2. **Implement proper error handling and user feedback**
3. **Use consistent UI patterns across the application**
4. **Follow Flutter and Firebase best practices**
5. **Regular testing of moderation workflows**
6. **Monitor user engagement and adjust features accordingly**
7. **Keep content guidelines updated and visible**
8. **Provide clear communication about moderation decisions**

## Emergency Procedures

### Crisis Content Detection

If testimony contains crisis indicators (suicide ideation, immediate harm):

1. Immediately flag for urgent review
2. Notify mental health professionals
3. Provide crisis resources to the author
4. Follow established crisis intervention protocols

### Security Incidents

For data breaches or security issues:

1. Immediately secure the system
2. Notify relevant authorities if required
3. Inform affected users transparently
4. Implement additional security measures
5. Conduct post-incident review
