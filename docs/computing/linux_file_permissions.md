## Understanding File Permissions in Linux: Numeric vs. Symbolic Notation

### Symbolic Notation

Symbolic notation uses characters to represent user categories and permissions:

- **User Categories**:
  - `u`: User (owner)
  - `g`: Group
  - `o`: Others
  - `a`: All

- **Permissions**:
  - `r`: Read
  - `w`: Write
  - `x`: Execute

- **Operators**:
  - `+`: Add a permission
  - `-`: Remove a permission
  - `=`: Set specific permissions

### Examples

1. **Add execute permission to the owner**:
   \`\`\`bash
   chmod u+x filename
   \`\`\`

2. **Remove write permission from the group**:
   \`\`\`bash
   chmod g-w filename
   \`\`\`

3. **Set read and execute permissions for all users**:
   \`\`\`bash
   chmod a+rx filename
   \`\`\`

4. **Make a file readable and writable by the user and group, but not accessible by others**:
   \`\`\`bash
   chmod u=rw,g=rw,o= filename
   \`\`\`

5. **Remove all permissions for others**:
   \`\`\`bash
   chmod o-rwx filename
   \`\`\`

6. **Set full permissions for the owner, and read/execute for group and others**:
   \`\`\`bash
   chmod u=rwx,g=rx,o=rx filename
   \`\`\`

### Advantages of Symbolic Notation

- **Readability**: Easier to understand what permissions are being set or changed.
- **Granularity**: Allows specific modifications without affecting other permissions.
- **Flexibility**: Easy to add, remove, or set permissions incrementally.

### Combining Changes

You can combine multiple changes in one command:

\`\`\`bash
chmod u+rwx,g+r,o= filename
\`\`\`

This sets:
- Full permissions for the user.
- Read permission for the group.
- No permissions for others.

### Summary

- **Numeric (Octal) Notation**: Sets all permissions at once using numbers.
- **Symbolic Notation**: Modifies or sets specific permissions in a descriptive way, providing better readability and granularity.

Symbolic notation is particularly useful for making incremental changes to file permissions.